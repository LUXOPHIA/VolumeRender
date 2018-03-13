unit LUX.FMX.Context.DX11;

{.$DEFINE DXDEBUG}

interface //#################################################################### ■

{$SCOPEDENUMS ON}

uses Winapi.DXGI, Winapi.D3D11, Winapi.D3DCommon,
     System.Types, System.UITypes, System.SysUtils, System.Classes,
     System.Math, System.Generics.Collections, System.Math.Vectors,
     FMX.Types3D, FMX.Types;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     TLuxCustomDX11Context = class( TContext3D )
     private class var
       _DriverType          :D3D_DRIVER_TYPE;
       _FeatureLevel        :D3D_FEATURE_LEVEL;
       _DriverSupportTested :Boolean;
       _SharedDevice        :ID3D11Device;
       _SharedContext       :ID3D11DeviceContext;
       _DXGIFactory         :IDXGIFactory;
       _VB                  :ID3D11Buffer;
       _IB                  :ID3D11Buffer;
       _VBLockPos           :Integer;
       _IBLockPos           :Integer;
       _BlankTexture        :ID3D11Texture2D;
     private
       ///// メソッド
       class function GetSharedDevice :ID3D11Device; static;
       class procedure CreateSharedDevice; static;
       class function GetDXGIFactory :IDXGIFactory; static;
       class procedure CreateBlankTexture; static;
       class function GetBlankTexture :ID3D11Texture2D; static;
       class function GetSharedContext :ID3D11DeviceContext; static;
       class function GetFeatureLevel :D3D_FEATURE_LEVEL; static;
     protected
       ///// メソッド
       function GetIndexBufferSupport :TContext3D.TIndexBufferSupport; override;
     public
       ///// プロパティ
       class property FeatureLevel  :D3D_FEATURE_LEVEL   read GetFeatureLevel ;
       class property SharedDevice  :ID3D11Device        read GetSharedDevice ;
       class property SharedContext :ID3D11DeviceContext read GetSharedContext;
       class property DXGIFactory   :IDXGIFactory        read GetDXGIFactory  ;
       class property BlankTexture  :ID3D11Texture2D     read GetBlankTexture ;
       ///// メソッド
       class procedure DestroySharedDevice; static;
       class procedure TestDriverSupport( out DriverType_:D3D_DRIVER_TYPE; out FeatureLevel_:TD3D_FEATURE_LEVEL );
       class function PixelFormat :TPixelFormat; override;
       class function MaxTextureSize :Integer; override;
     end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

procedure RegisterContextClasses;
procedure UnregisterContextClasses;

implementation //############################################################### ■

uses Winapi.Windows, Winapi.DXTypes, Winapi.DxgiType, Winapi.DxgiFormat,
     System.Win.ComObj,
     FMX.Forms, FMX.Platform.Win, FMX.Context.DX9, FMX.Canvas.GPU,
     FMX.Graphics, FMX.Consts, FMX.Utils, FMX.Platform,
     LUX.FMX.Types3D;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     TLuxDX11Context = class( TLuxCustomDX11Context )
     private class var
       _Resources               :IInterfaceList;
       _VSSlot                  :ID3D11Buffer;
       _PSSlot                  :ID3D11Buffer;
       _VSSlotModified          :Boolean;
       _PSSlotModified          :Boolean;
       _VSBuf                   :array of Byte;
       _PSBuf                   :array of Byte;
       _InputLayout             :ID3D11InputLayout;
       _ResourceViews           :array [ 0..16 ] of ID3D11ShaderResourceView;
       _SampleStates            :array [ 0..16 ] of ID3D11SamplerState;
       _BlendDesc               :TD3D11_BLEND_DESC;
       _BlendState              :ID3D11BlendState;
       _BlendStateModified      :Boolean;
       _RasterizerDesc          :TD3D11_RASTERIZER_DESC;
       _RasterizerState         :ID3D11RasterizerState;
       _RasterizerStateModified :Boolean;
       _DepthStencilDesc        :TD3D11_DEPTH_STENCIL_DESC;
       _DepthStencilState       :ID3D11DepthStencilState;
       _DepthStencilModified    :Boolean;
       _StencilRef              :Integer;
       _BufferSize              :TSize;
     private
       ///// メソッド
       class function AddResource( const Resource_:IInterface ) :THandle;
       class procedure RemoveResource( Resource_:THandle );
       class function ResourceToVertexShader( Resource_:THandle ) :ID3D11VertexShader;
       class function ResourceToPixelShader( Resource_:THandle ) :ID3D11PixelShader;
       class function ResourceToTexture( Resource_:THandle ) :ID3D11Texture2D;
       class function ResourceToTexture3D( Resource_:THandle ) :ID3D11Texture3D;
     private
       { states }
       _SavedRT           :ID3D11RenderTargetView;
       _SavedDepth        :ID3D11DepthStencilView;
       _SavedViewportNum  :Cardinal;
       _SavedViewport     :TD3D11_Viewport;
       { swapchain }
       _SwapChain         :IDXGISwapChain;
       _RenderTargetView  :ID3D11RenderTargetView;
       _DepthStencilTex   :ID3D11Texture2D;
       _DepthStencilView  :ID3D11DepthStencilView;
       { ms }
       _RenderTargetMSTex :ID3D11Texture2D;
       { copy }
       _CopyBuffer        :ID3D11Texture2D;
       ///// メソッド
       procedure FindBestMultisampleType( Format_:DXGI_FORMAT; Multisample_:TMultisample; out SampleCount_,QualityLevel_:Integer );
       procedure SetTexture( const Unit_:Integer; const Texture_:TTexture );
       procedure SetTexture2D( const Unit_:Integer; const Texture_:TTexture );
       procedure SetTexture3D( const Unit_:Integer; const Texture_:TTexture3D );
       class procedure FindBestShaderSource( const Shader_:TContextShader; out Source_:TContextShaderSource );
     protected
       ///// メソッド
       { buffer }
       procedure DoCreateBuffer; override;
       procedure DoResize; override;
       procedure DoFreeBuffer; override;
       procedure DoCopyToBitmap( const Dest_:TBitmap; const Rect_:TRect ); override;
       procedure DoCopyToBits( const Bits_:Pointer; const Pitch_:Integer; const Rect_:TRect ); override;
       { scene }
       function DoBeginScene :Boolean; override;
       procedure DoEndScene; override;
       { states }
       procedure DoClear( const Target_:TClearTargets; const Color_:TAlphaColor; const Depth_:Single; const Stencil_:Cardinal ); override;
       procedure DoSetContextState( State_:TContextState ); override;
       procedure DoSetStencilOp( const Fail_,ZFail_,ZPass_:TStencilOp ); override;
       procedure DoSetStencilFunc( const Func_:TStencilfunc; Ref_,Mask_:Cardinal ); override;
       procedure DoSetScissorRect( const ScissorRect_:TRect ); override;
       { drawing }
       procedure DoDrawPrimitivesBatch( const Kind_:TPrimitivesKind; const Vertices_,Indices_:Pointer; const VertexDeclaration_:TVertexDeclaration; const VertexSize_,VertexCount_,IndexSize_,IndexCount_:Integer ); override;
       { texture }
       class procedure DoInitializeTexture( const Texture_:TTexture ); override;
       class procedure DoInitializeTexture2D( const Texture_:TTexture );
       class procedure DoInitializeTexture3D( const Texture_:TTexture3D );
       class procedure DoFinalizeTexture( const Texture_:TTexture ); override;
       class procedure DoUpdateTexture( const Texture_:TTexture; const Bits_:Pointer; const Pitch_:Integer ); override;
       class procedure DoUpdateTexture2D( const Texture_:TTexture; const Bits_:Pointer; const Pitch_:Integer );
       class procedure DoUpdateTexture3D( const Texture_:TTexture3D );
       { bitmap }
       class function DoBitmapToTexture( const Bitmap_:TBitmap ): TTexture; override;
       { shaders }
       class procedure DoInitializeShader( const Shader_:TContextShader ); override;
       class procedure DoFinalizeShader( const Shader_:TContextShader ); override;
       procedure DoSetShaders( const VertexShader_,PixelShader_:TContextShader ); override;
       procedure DoSetShaderVariable( const Name_:string; const Data_:array of TVector3D ); overload; override;
       procedure DoSetShaderVariable( const Name_:string; const Texture_:TTexture ); overload; override;
       procedure DoSetShaderVariable( const Name_:string; const Matrix_:TMatrix3D ); overload; override;
       { constructors }
       constructor CreateFromWindow( const Parent_:TWindowHandle; const Width_,Height_:Integer; const Multisample_:TMultisample; const DepthStencil_:Boolean ); override;
       constructor CreateFromTexture( const Texture_:TTexture; const Multisample_:TMultisample; const DepthStencil_:Boolean ); override;
       class function PixelFormat :TPixelFormat; override;
     end;

var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

    HR           :HResult;
    VBSize       :Integer = $FFFF * 56;
    IBSize       :Integer = $FFFF * 2 * 2;

    PrevFPUState :TArithmeticExceptionMask;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

procedure SaveClearFPUState; inline;
begin
     PrevFPUState := GetExceptionMask;

     SetExceptionMask( exAllArithmeticExceptions );
end;

procedure RestoreFPUState; inline;
begin
     SetExceptionMask( PrevFPUState );
end;

function ColorToD3DColor( const Color_:TAlphaColor ) :TFourSingleArray;
begin
     Result[ 0 ] := TAlphaColorRec( Color_ ).R / $FF;
     Result[ 1 ] := TAlphaColorRec( Color_ ).G / $FF;
     Result[ 2 ] := TAlphaColorRec( Color_ ).B / $FF;
     Result[ 3 ] := TAlphaColorRec( Color_ ).A / $FF;
end;

function TexturePixelFormatToDX( PF_:TPixelFormat ) :DXGI_FORMAT;
begin
     case PF_ of
       TPixelFormat.RGBA16  : Result := DXGI_FORMAT_R16G16B16A16_UNORM;
       TPixelFormat.RGB10_A2: Result := DXGI_FORMAT_R10G10B10A2_UNORM ;
       TPixelFormat.BGRA    : Result := DXGI_FORMAT_B8G8R8A8_UNORM    ;
       TPixelFormat.BGR     : Result := DXGI_FORMAT_B8G8R8X8_UNORM    ;
       TPixelFormat.RGBA    : Result := DXGI_FORMAT_R8G8B8A8_UNORM    ;
       TPixelFormat.BGR_565 : Result := DXGI_FORMAT_B5G6R5_UNORM      ;
       TPixelFormat.BGR5_A1 : Result := DXGI_FORMAT_B5G5R5A1_UNORM    ;
       TPixelFormat.LA      : Result := DXGI_FORMAT_R8G8_UNORM        ;
       TPixelFormat.R16F    : Result := DXGI_FORMAT_R16_FLOAT         ;
       TPixelFormat.RG16F   : Result := DXGI_FORMAT_R16G16_FLOAT      ;
       TPixelFormat.RGBA16F : Result := DXGI_FORMAT_R16G16B16A16_FLOAT;
       TPixelFormat.R32F    : Result := DXGI_FORMAT_R32_FLOAT         ;
       TPixelFormat.RG32F   : Result := DXGI_FORMAT_R32G32_FLOAT      ;
       TPixelFormat.RGBA32F : Result := DXGI_FORMAT_R32G32B32A32_FLOAT;
       TPixelFormat.A       : Result := DXGI_FORMAT_A8_UNORM          ;
     else                     Result := DXGI_FORMAT_UNKNOWN           ;
     end;
end;

function GetSlotSize( const Source_:TContextShaderSource ) :Integer;
var
   I :Integer;
begin
     Result := 0;

     for I := 0 to High( Source_.Variables ) do Result := Result + Max( Source_.Variables[ I ].Size, 16 );
end;

function D3D11CreateDevice1Ex( DriverType_:D3D_DRIVER_TYPE; Flags_:LongWord; out Device_:ID3D11Device; out Context_:ID3D11DeviceContext; out FeatureLevel_:TD3D_FEATURE_LEVEL ) :HResult;
const
     RequestLevels :array [ 0..5 ] of D3D_FEATURE_LEVEL = ( D3D_FEATURE_LEVEL_11_0,
                                                            D3D_FEATURE_LEVEL_10_1,
                                                            D3D_FEATURE_LEVEL_10_0,
                                                            D3D_FEATURE_LEVEL_9_3 ,
                                                            D3D_FEATURE_LEVEL_9_2 ,
                                                            D3D_FEATURE_LEVEL_9_1  );
     DX9Levels     :array [ 0..2 ] of D3D_FEATURE_LEVEL = ( D3D_FEATURE_LEVEL_9_3 ,
                                                            D3D_FEATURE_LEVEL_9_2 ,
                                                            D3D_FEATURE_LEVEL_9_1  );
begin
     if GlobalUseDXInDX9Mode then Result := D3D11CreateDevice( nil, DriverType_, 0, Flags_, @DX9Levels    [ 0 ], Length( DX9Levels     ), D3D11_SDK_VERSION, Device_, FeatureLevel_, Context_ )
                             else Result := D3D11CreateDevice( nil, DriverType_, 0, Flags_, @RequestLevels[ 0 ], Length( RequestLevels ), D3D11_SDK_VERSION, Device_, FeatureLevel_, Context_ );
end;

class function TLuxCustomDX11Context.GetBlankTexture :ID3D11Texture2D;
begin
     CreateBlankTexture;

     Result := _BlankTexture;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TCustomDX11Context

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// メソッド

class function TLuxCustomDX11Context.GetSharedDevice :ID3D11Device;
begin
     CreateSharedDevice;

     Result := _SharedDevice;
end;

class procedure TLuxCustomDX11Context.CreateSharedDevice;
var
   Flags :Cardinal;
   DXGIDevice :IDXGIDevice;
   DXGIAdapter :IDXGIAdapter;
   {$IFDEF DXDEBUG}
   DebugText :string;
   {$ENDIF}
begin
     if _SharedDevice = nil then
     begin
          SaveClearFPUState;

          try
             Flags := {$IFDEF DXDEBUG}D3D11_CREATE_DEVICE_DEBUG{$ELSE}0{$ENDIF};
             Flags := Flags or D3D11_CREATE_DEVICE_BGRA_SUPPORT;

             if Succeeded( D3D11CreateDevice1Ex( _DriverType, Flags, _SharedDevice, _SharedContext, _FeatureLevel ) ) then
             begin
                  HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( VBSize, D3D11_BIND_VERTEX_BUFFER, D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _VB );
                  HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( IBSize, D3D11_BIND_INDEX_BUFFER , D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _IB );

                   DXGIAdapter := nil;
                  _DXGIFactory := nil;

                  if Succeeded( _SharedDevice.QueryInterface( IDXGIDevice, DXGIDevice ) ) and ( DXGIDevice <> nil ) and Succeeded( DXGIDevice.GetParent( IDXGIAdapter, DXGIAdapter ) ) and ( DXGIAdapter <> nil ) then
                  begin
                       DXGIAdapter.GetParent( IDXGIFactory, _DXGIFactory );
                  end;

                  if _DXGIFactory = nil then raise ECannotAcquireDXGIFactory.CreateFmt( SCannotAcquireDXGIFactory, [ ClassName ] );
             end
             else raise ECannotCreateD3DDevice.CreateFmt( SCannotCreateD3DDevice, [ ClassName ] );

          finally
                 RestoreFPUState;
          end;

          {$IFDEF DXDEBUG}
          case FFeatureLevel of
            D3D_FEATURE_LEVEL_9_1 : DebugText := '9.1';
            D3D_FEATURE_LEVEL_9_2 : DebugText := '9.2';
            D3D_FEATURE_LEVEL_9_3 : DebugText := '9.3';
            D3D_FEATURE_LEVEL_10_0: DebugText := '10.0';
            D3D_FEATURE_LEVEL_10_1: DebugText := '10.1';
            D3D_FEATURE_LEVEL_11_0: DebugText := '11.0';
          else                      DebugText := 'unknown';
          end;

          if FDriverType = D3D_DRIVER_TYPE_HARDWARE then DebugText := DebugText + ' (HAL)'
                                                    else DebugText := DebugText + ' (WARP)';

          OutputDebugString( PChar( 'DX11Context is using Feature Level ' + DebugText ) );
          {$ENDIF}

          FillChar( TLuxDX11Context._BlendDesc, SizeOf( TLuxDX11Context._BlendDesc ), 0 );

          TLuxDX11Context._BlendDesc.AlphaToCoverageEnable                   := False;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].BlendEnable           := True;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].SrcBlend              := D3D11_BLEND_ONE;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].DestBlend             := D3D11_BLEND_INV_SRC_ALPHA;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].BlendOp               := D3D11_BLEND_OP_ADD;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].SrcBlendAlpha         := D3D11_BLEND_ONE;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].DestBlendAlpha        := D3D11_BLEND_INV_SRC_ALPHA;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].BlendOpAlpha          := D3D11_BLEND_OP_ADD;
          TLuxDX11Context._BlendDesc.RenderTarget[ 0 ].RenderTargetWriteMask := Byte( D3D11_COLOR_WRITE_ENABLE_ALL );
          TLuxDX11Context._BlendStateModified                                := True;

          TLuxDX11Context._RasterizerDesc.FillMode              := D3D11_FILL_SOLID;
          TLuxDX11Context._RasterizerDesc.CullMode              := D3D11_CULL_BACK;
          TLuxDX11Context._RasterizerDesc.FrontCounterClockwise := False;
          TLuxDX11Context._RasterizerDesc.DepthBias             := 0;
          TLuxDX11Context._RasterizerDesc.DepthBiasClamp        := 0;
          TLuxDX11Context._RasterizerDesc.SlopeScaledDepthBias  := 0;
          TLuxDX11Context._RasterizerDesc.DepthClipEnable       := True;
          TLuxDX11Context._RasterizerDesc.ScissorEnable         := False;
          TLuxDX11Context._RasterizerDesc.MultisampleEnable     := True;
          TLuxDX11Context._RasterizerDesc.AntialiasedLineEnable := True;
          TLuxDX11Context._RasterizerStateModified              := True;

          FillChar( TLuxDX11Context._DepthStencilDesc, SizeOf( TLuxDX11Context._DepthStencilDesc ), 0 );

          TLuxDX11Context._DepthStencilDesc.DepthEnable    := False;
          TLuxDX11Context._DepthStencilDesc.DepthWriteMask := D3D11_DEPTH_WRITE_MASK_ALL;
          TLuxDX11Context._DepthStencilDesc.DepthFunc      := D3D11_COMPARISON_LESS_EQUAL;
          TLuxDX11Context._DepthStencilDesc.StencilEnable  := False;
          TLuxDX11Context._DepthStencilModified            := True;
          TLuxDX11Context._StencilRef                      := 0;
     end;
end;

class function TLuxCustomDX11Context.GetDXGIFactory :IDXGIFactory;
begin
     CreateSharedDevice;

     Result := _DXGIFactory;
end;

class procedure TLuxCustomDX11Context.CreateBlankTexture;
var
   Desc :TD3D11_TEXTURE2D_DESC;
   Data :D3D11_SUBRESOURCE_DATA;
   Color :UInt;
begin
     CreateSharedDevice;

     FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

     Desc.Format             := DXGI_FORMAT_B8G8R8A8_UNORM;
     Desc.Width              := 1;
     Desc.Height             := 1;
     Desc.MipLevels          := 1;
     Desc.ArraySize          := 1;
     Desc.SampleDesc.Count   := 1;
     Desc.SampleDesc.Quality := 0;
     Desc.Usage              := D3D11_USAGE_IMMUTABLE;
     Desc.BindFlags          := D3D11_BIND_SHADER_RESOURCE;

     Color := $FFFFFFFF;

     Data.pSysMem          := @Color;
     Data.SysMemPitch      := 4;
     Data.SysMemSlicePitch := 0;

     SaveClearFPUState;

     try
        HR := SharedDevice.CreateTexture2D( Desc, @Data, _BlankTexture );

     finally
            RestoreFPUState;
     end;
end;

class function TLuxCustomDX11Context.GetSharedContext :ID3D11DeviceContext;
begin
     CreateSharedDevice;

     Result := _SharedContext;
end;

class function TLuxCustomDX11Context.GetFeatureLevel :D3D_FEATURE_LEVEL;
begin
     CreateSharedDevice;

     Result := _FeatureLevel;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

function TLuxCustomDX11Context.GetIndexBufferSupport :TContext3D.TIndexBufferSupport;
begin
     if _FeatureLevel > D3D_FEATURE_LEVEL_9_1 then Result := TIndexBufferSupport.Int32
                                              else Result := TIndexBufferSupport.Int16;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

class procedure TLuxCustomDX11Context.DestroySharedDevice;
begin
     _VB           := nil;
     _IB           := nil;
     _DXGIFactory  := nil;
     _BlankTexture := nil;
     _SharedDevice := nil;
end;

class procedure TLuxCustomDX11Context.TestDriverSupport( out DriverType_:D3D_DRIVER_TYPE; out FeatureLevel_:TD3D_FEATURE_LEVEL );
var
   DX11Lib :THandle;
   Device :ID3D11Device;
   Context :ID3D11DeviceContext;
begin
     if not _DriverSupportTested then
     begin
          _DriverSupportTested := True;

          _DriverType := D3D_DRIVER_TYPE_NULL;

          _FeatureLevel := D3D_FEATURE_LEVEL_11_0;

          DX11Lib := LoadLibrary( D3D11dll );

          if DX11Lib <> 0 then
          try
             if GlobalUseDX then
             begin
                  SaveClearFPUState;
                  try
                     if ( not GlobalUseDXSoftware ) and Succeeded( D3D11CreateDevice1Ex( D3D_DRIVER_TYPE_HARDWARE, D3D11_CREATE_DEVICE_BGRA_SUPPORT, Device, Context, _FeatureLevel ) ) then
                     begin
                          Device := nil;

                          Context := nil;

                          _DriverType := D3D_DRIVER_TYPE_HARDWARE;
                     end
                     else
                     if Succeeded( D3D11CreateDevice1Ex( D3D_DRIVER_TYPE_WARP, D3D11_CREATE_DEVICE_BGRA_SUPPORT, Device, Context, _FeatureLevel ) ) then
                     begin
                          Device := nil;

                          Context := nil;

                         _DriverType := D3D_DRIVER_TYPE_WARP;
                     end;
                  finally
                         RestoreFPUState;
                  end;
             end;
          finally
                 FreeLibrary( DX11Lib );
          end;
     end;

     DriverType_ := _DriverType;

     FeatureLevel_ := _FeatureLevel;
end;

class function TLuxCustomDX11Context.PixelFormat :TPixelFormat;
begin
     Result := TPixelFormat.BGRA;
end;

class function TLuxCustomDX11Context.MaxTextureSize :Integer;
begin
     CreateSharedDevice;

     case _FeatureLevel of
       D3D_FEATURE_LEVEL_9_1 : Result :=  2048;
       D3D_FEATURE_LEVEL_9_2 : Result :=  2048;
       D3D_FEATURE_LEVEL_9_3 : Result :=  4096;
       D3D_FEATURE_LEVEL_10_0: Result :=  8192;
       D3D_FEATURE_LEVEL_10_1: Result :=  8192;
       D3D_FEATURE_LEVEL_11_0: Result := 16384;
     else begin
               if _FeatureLevel > D3D_FEATURE_LEVEL_11_0 then Result := 16384
                                                         else Result :=  2048;
          end;
     end;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TDX11Context

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// メソッド

class function TLuxDX11Context.AddResource( const Resource_:IInterface ) :THandle;
begin
     if _Resources = nil then
     begin
          _Resources := TInterfaceList.Create;
          // Fill in the first slot with a dummy entry. This will make it so that a TContextShader value of 0 is invalid.
          _Resources.Add( TInterfacedObject.Create );
     end;

     Result := 0;

     while ( Result < UInt( _Resources.Count ) ) and ( _Resources[ Result ] <> nil ) do Inc( Result );

     if Result < UInt( _Resources.Count ) then _Resources[ Result ] := Resource_
                                          else             Result   := _Resources.Add( Resource_ );
end;

class procedure TLuxDX11Context.RemoveResource( Resource_:THandle );
begin
     if ( _Resources <> nil ) and ( Resource_ <> 0 ) then _Resources[ Resource_ ] := nil;
end;

class function TLuxDX11Context.ResourceToVertexShader( Resource_:THandle ) :ID3D11VertexShader;
begin
     if ( _Resources <> nil ) and ( Resource_ > 0 ) and ( Resource_ < UInt( _Resources.Count ) ) then Result := _Resources[ Resource_ ] as ID3D11VertexShader
                                                                                                 else Result := nil;
end;

class function TLuxDX11Context.ResourceToPixelShader( Resource_:THandle ) :ID3D11PixelShader;
begin
     if ( _Resources <> nil ) and ( Resource_ > 0 ) and ( Resource_ < UInt( _Resources.Count ) ) then Result := _Resources[ Resource_ ] as ID3D11PixelShader
                                                                                                 else Result := nil;
end;

class function TLuxDX11Context.ResourceToTexture( Resource_:THandle ) :ID3D11Texture2D;
begin
     if ( _Resources <> nil ) and ( Resource_ > 0 ) and ( Resource_ < UInt( _Resources.Count ) ) then Result := _Resources[ Resource_ ] as ID3D11Texture2D
                                                                                                 else Result := nil;
end;

class function TLuxDX11Context.ResourceToTexture3D( Resource_:THandle ) :ID3D11Texture3D;
begin
     if ( _Resources <> nil ) and ( Resource_ > 0 ) and ( Resource_ < UInt( _Resources.Count ) ) then Result := _Resources[ Resource_ ] as ID3D11Texture3D
                                                                                                 else Result := nil;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TLuxDX11Context.FindBestMultisampleType( Format_:DXGI_FORMAT; Multisample_:TMultisample; out SampleCount_,QualityLevel_:Integer );
var
   I, MaxSampleNo :Integer;
   QuaLevels :Cardinal;
   MultisampleCount :Integer;
begin
     if Multisample_ = TMultisample.FourSamples then MultisampleCount := 4
                                                else
     if Multisample_ = TMultisample.TwoSamples  then MultisampleCount := 2
                                                else MultisampleCount := 1;

     SampleCount_ := 1;

     QualityLevel_ := 0;

     if ( SharedDevice = nil ) or ( MultisampleCount < 2 ) or ( Format_ = DXGI_FORMAT_UNKNOWN ) then Exit;

     MaxSampleNo := Min( MultisampleCount, D3D11_MAX_MULTISAMPLE_SAMPLE_COUNT );

     SaveClearFPUState;

     try
        for I := MaxSampleNo downto 2 do
        begin
             if Failed( SharedDevice.CheckMultisampleQualityLevels( Format_, I, QuaLevels ) ) then Continue;

             if QuaLevels > 0 then
             begin
                  SampleCount_ := I;

                  QualityLevel_ := QuaLevels - 1;

                  Break;
             end;
        end;
     finally
            RestoreFPUState;
     end;
end;

procedure TLuxDX11Context.SetTexture( const Unit_:Integer; const Texture_:TTexture );
begin
     if Texture_ is TTexture3D then SetTexture3D( Unit_, Texture_ as TTexture3D )
                               else SetTexture2D( Unit_, Texture_ );
end;

procedure TLuxDX11Context.SetTexture2D( const Unit_:Integer; const Texture_:TTexture );
var
   Tex :ID3D11Texture2D;
   Desc :TD3D11_SAMPLER_DESC;
   OldResourceView :ID3D11ShaderResourceView;
   OldSampleState :ID3D11SamplerState;
begin
     SaveClearFPUState;

     try
        if _SampleStates[ Unit_ ] = nil then
        begin
             FillChar( Desc, SizeOf( Desc ), 0);

             Desc.AddressU       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.AddressV       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.AddressW       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.Filter         := D3D11_FILTER_MIN_MAG_MIP_LINEAR;
             Desc.MipLODBias     := 0;
             Desc.MaxAnisotropy  := 1;
             Desc.ComparisonFunc := D3D11_COMPARISON_NEVER;
             Desc.MinLOD         := -Single.MaxValue;
             Desc.MaxLOD         := +Single.MaxValue;

             OldSampleState := _SampleStates[ Unit_ ];

             _SampleStates[ Unit_ ] := nil;

             if Succeeded( SharedDevice.CreateSamplerState( Desc, _SampleStates[ Unit_ ] ) ) then
             begin
                  SharedContext.PSSetSamplers( Unit_, 1, _SampleStates[ Unit_ ] );

                  OldSampleState := nil;
             end;
        end;

        if ( Texture_ <> nil ) and ( Texture_.Handle <> 0 ) then Tex := ResourceToTexture( Texture_.Handle )
                                                            else Tex := BlankTexture;

        OldResourceView := _ResourceViews[ Unit_ ];

        _ResourceViews[ Unit_ ] := nil;

        if Succeeded( SharedDevice.CreateShaderResourceView( Tex, nil, _ResourceViews[ Unit_ ] ) ) then
        begin
             SharedContext.PSSetShaderResources( Unit_, 1, _ResourceViews[ Unit_ ] );

             OldResourceView := nil;
        end;
     finally
            RestoreFPUState;
     end;
end;

procedure TLuxDX11Context.SetTexture3D( const Unit_:Integer; const Texture_:TTexture3D );
var
   Tex :ID3D11Texture3D;
   Desc :TD3D11_SAMPLER_DESC;
   OldResourceView :ID3D11ShaderResourceView;
   OldSampleState :ID3D11SamplerState;
begin
     SaveClearFPUState;
     try
        if _SampleStates[ Unit_ ] = nil then
        begin
             FillChar( Desc, SizeOf( Desc ), 0 );

             Desc.AddressU       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.AddressV       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.AddressW       := D3D11_TEXTURE_ADDRESS_CLAMP;
             Desc.Filter         := D3D11_FILTER_MIN_MAG_MIP_LINEAR;
             Desc.MipLODBias     := 0;
             Desc.MaxAnisotropy  := 1;
             Desc.ComparisonFunc := D3D11_COMPARISON_NEVER;
             Desc.MinLOD         := -Single.MaxValue;
             Desc.MaxLOD         := +Single.MaxValue;

             OldSampleState := _SampleStates[ Unit_ ];

             _SampleStates[ Unit_ ] := nil;

             if Succeeded( SharedDevice.CreateSamplerState( Desc, _SampleStates[ Unit_ ] ) ) then
             begin
                  SharedContext.PSSetSamplers( Unit_, 1, _SampleStates[ Unit_ ] );

                  OldSampleState := nil;
             end;
        end;

        if ( Texture_ <> nil ) and ( Texture_.Handle <> 0 ) then
        begin
             Tex := ResourceToTexture3D( Texture_.Handle );
        end
        else Assert( False, 'Tex := BlankTexture' );

        OldResourceView := _ResourceViews[ Unit_ ];

        _ResourceViews[ Unit_ ] := nil;

        if Succeeded( SharedDevice.CreateShaderResourceView( Tex, nil, _ResourceViews[ Unit_ ] ) ) then
        begin
             SharedContext.PSSetShaderResources( Unit_, 1, _ResourceViews[ Unit_ ] );

             OldResourceView := nil;
        end;
     finally
            RestoreFPUState;
     end;
end;

class procedure TLuxDX11Context.FindBestShaderSource( const Shader_:TContextShader; out Source_:TContextShaderSource );
var
   MatchFound :Boolean;
begin
     MatchFound := False;

     if TLuxCustomDX11Context.FeatureLevel >= D3D_FEATURE_LEVEL_11_0 then
     begin
          Source_ := Shader_.GetSourceByArch( TContextShaderArch.DX11 );

          MatchFound := Source_.IsDefined;
     end;

     if not MatchFound and ( TLuxCustomDX11Context.FeatureLevel >= D3D_FEATURE_LEVEL_10_0 ) then
     begin
          Source_ := Shader_.GetSourceByArch( TContextShaderArch.DX10 );

          MatchFound := Source_.IsDefined;
     end;

     if not MatchFound and ( TLuxCustomDX11Context.FeatureLevel >= D3D_FEATURE_LEVEL_9_1 ) then
     begin
          Source_ := Shader_.GetSourceByArch( TContextShaderArch.DX11_level_9 );

          MatchFound := Source_.IsDefined;
     end;

     if not MatchFound then raise ECannotFindShader.CreateFmt( SCannotFindSuitableShader, [ Shader_.Name ] );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

procedure TLuxDX11Context.DoCreateBuffer;
var
   Tex :ID3D11Texture2D;
   BackBuffer :ID3D11Texture2D;
   SwapDesc :TDXGISwapChainDesc;
   SampleCount, QualityLevel :Integer;
   TexDesc, Desc :TD3D11_TEXTURE2D_DESC;
   Multisamples, ColorBits, DepthBits :Integer;
   Stencil :Boolean;
   RenderingSetupService :IFMXRenderingSetupService;
begin
     SaveClearFPUState;

     try
        if Texture <> nil then
        begin
             FindBestMultisampleType( TexturePixelFormatToDX( Texture.PixelFormat ), Multisample, SampleCount, QualityLevel );

             if ( Multisample <> TMultisample.None ) and ( SampleCount > 1 ) then
             begin
                  FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

                  Desc.Format             := TexturePixelFormatToDX( Texture.PixelFormat );
                  Desc.Width              := Texture.Width;
                  Desc.Height             := Texture.Height;
                  Desc.MipLevels          := 1;
                  Desc.ArraySize          := 1;
                  Desc.SampleDesc.Count   := SampleCount;
                  Desc.SampleDesc.Quality := QualityLevel;
                  Desc.Usage              := D3D11_USAGE_DEFAULT;
                  Desc.BindFlags          := D3D11_BIND_RENDER_TARGET;

                  SaveClearFPUState;

                  try
                     HR := SharedDevice.CreateTexture2D( Desc, nil, _RenderTargetMSTex );
                  finally
                         RestoreFPUState;
                  end;

                  if _RenderTargetMSTex <> nil then
                  begin
                       HR := SharedDevice.CreateRenderTargetView( _RenderTargetMSTex, nil, _RenderTargetView );

                       if DepthStencil then
                       begin
                            _RenderTargetMSTex.GetDesc( TexDesc );

                            FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

                            Desc.Format             := DXGI_FORMAT_D24_UNORM_S8_UINT;
                            Desc.Width              := TexDesc.Width;
                            Desc.Height             := TexDesc.Height;
                            Desc.MipLevels          := 1;
                            Desc.ArraySize          := 1;
                            Desc.SampleDesc.Count   := SampleCount;
                            Desc.SampleDesc.Quality := QualityLevel;
                            Desc.Usage              := D3D11_USAGE_DEFAULT;
                            Desc.BindFlags          := D3D11_BIND_DEPTH_STENCIL;

                            HR := SharedDevice.CreateTexture2D( Desc, nil, _DepthStencilTex );

                            if Succeeded( HR ) then HR := SharedDevice.CreateDepthStencilView( _DepthStencilTex, nil, _DepthStencilView );
                       end;
                  end;
             end
             else
             begin
                  Tex := ResourceToTexture( Texture.Handle );

                  if Tex <> nil then
                  begin
                       Tex.GetDesc( TexDesc );

                       HR := SharedDevice.CreateRenderTargetView( Tex, nil, _RenderTargetView );

                       if DepthStencil then
                       begin
                            FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

                            Desc.Format             := DXGI_FORMAT_D24_UNORM_S8_UINT;
                            Desc.Width              := TexDesc.Width;
                            Desc.Height             := TexDesc.Height;
                            Desc.MipLevels          := 1;
                            Desc.ArraySize          := 1;
                            Desc.SampleDesc.Count   := 1;
                            Desc.SampleDesc.Quality := 0;
                            Desc.Usage              := D3D11_USAGE_DEFAULT;
                            Desc.BindFlags          := D3D11_BIND_DEPTH_STENCIL;

                            HR := SharedDevice.CreateTexture2D( Desc, nil, _DepthStencilTex );

                            if Succeeded( HR ) then HR := SharedDevice.CreateDepthStencilView( _DepthStencilTex, nil, _DepthStencilView );
                       end;
                  end;
             end;
        end
        else
        begin
             Multisamples := Ord( Multisample ) * 2;

             ColorBits := 0;

             DepthBits := 24;

             Stencil := DepthStencil;

             _BufferSize := TSize.Create( WindowHandleToPlatform( Parent ).WndClientSize.Width ,
                                          WindowHandleToPlatform( Parent ).WndClientSize.Height );

             if TPlatformServices.Current.SupportsPlatformService( IFMXRenderingSetupService, RenderingSetupService ) then RenderingSetupService.Invoke( ColorBits, DepthBits, Stencil, Multisamples );

             FillChar( SwapDesc, SizeOf( SwapDesc ), 0 );

             SwapDesc.BufferCount        := 1;
             SwapDesc.BufferDesc.Width   := _BufferSize.Width;
             SwapDesc.BufferDesc.Height  := _BufferSize.Height;
             SwapDesc.BufferDesc.Format  := DXGI_FORMAT_B8G8R8A8_UNORM;
             SwapDesc.BufferUsage        := DXGI_USAGE_RENDER_TARGET_OUTPUT;
             SwapDesc.OutputWindow       := WindowHandleToPlatform( Parent ).Wnd;

             FindBestMultisampleType( SwapDesc.BufferDesc.Format, TMultisample( Multisamples div 2 ), SampleCount, QualityLevel );

             SwapDesc.SampleDesc.Count   := SampleCount;
             SwapDesc.SampleDesc.Quality := QualityLevel;
             SwapDesc.Windowed           := True;

             HR := DXGIFactory.CreateSwapChain( SharedDevice, SwapDesc, _SwapChain );

             if Succeeded( HR ) then
             begin
                  DXGIFactory.MakeWindowAssociation( WindowHandleToPlatform( Parent ).Wnd, DXGI_MWA_NO_WINDOW_CHANGES );

                  HR := _SwapChain.GetBuffer( 0, ID3D11Texture2D, BackBuffer );

                  if Succeeded( HR ) then HR := SharedDevice.CreateRenderTargetView( BackBuffer, nil, _RenderTargetView );

                  if ( DepthBits > 0 ) or Stencil then
                  begin
                       FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

                       Desc.Format             := DXGI_FORMAT_D24_UNORM_S8_UINT;
                       Desc.Width              := SwapDesc.BufferDesc.Width;
                       Desc.Height             := SwapDesc.BufferDesc.Height;
                       Desc.MipLevels          := 1;
                       Desc.ArraySize          := 1;
                       Desc.SampleDesc.Count   := SwapDesc.SampleDesc.Count;
                       Desc.SampleDesc.Quality := SwapDesc.SampleDesc.Quality;
                       Desc.Usage              := D3D11_USAGE_DEFAULT;
                       Desc.BindFlags          := D3D11_BIND_DEPTH_STENCIL;

                       HR := SharedDevice.CreateTexture2D( Desc, nil, _DepthStencilTex );

                       if Succeeded( HR ) then HR := SharedDevice.CreateDepthStencilView( _DepthStencilTex, nil, _DepthStencilView );
                  end;
             end;
        end;
     finally
            RestoreFPUState;
     end;
end;

procedure TLuxDX11Context.DoResize;
begin
end;

procedure TLuxDX11Context.DoFreeBuffer;
begin
     _RenderTargetMSTex := nil;
     _SwapChain         := nil;
     _RenderTargetView  := nil;
     _DepthStencilTex   := nil;
     _DepthStencilView  := nil;
end;

procedure TLuxDX11Context.DoCopyToBitmap( const Dest_:TBitmap; const Rect_:TRect );
var
   CopyRect :TRect;
begin
     if ( TCanvasStyle.NeedGPUSurface in Dest_.CanvasClass.GetCanvasStyle ) and ( Texture <> nil ) then
     begin
          if TCustomCanvasGpu( Dest_.Canvas ).BeginScene then
          try
             CopyRect := TRect.Intersect( Rect_, TRect.Create( 0, 0, Width, Height ) );

             TCustomCanvasGpu( Dest_.Canvas ).Clear( 0 );
             TCustomCanvasGpu( Dest_.Canvas ).SetMatrix( TMatrix.Identity );
             TCustomCanvasGpu( Dest_.Canvas ).DrawTexture( TRectF.Create( CopyRect.Left, CopyRect.Top, CopyRect.Right, CopyRect.Bottom ),
                                                           TRectF.Create( 0, 0, CopyRect.Width, CopyRect.Height ),
                                                           $FFFFFFFF,
                                                           Texture );

          finally
                 TCustomCanvasGpu( Dest_.Canvas ).EndScene;
          end;
     end
     else inherited;
end;

procedure TLuxDX11Context.DoCopyToBits( const Bits_:Pointer; const Pitch_:Integer; const Rect_:TRect );
var
   Desc :TD3D11_TEXTURE2D_DESC;
   BackBuffer :ID3D11Texture2D;
   Mapped :TD3D11_MAPPED_SUBRESOURCE;
   I, W :UInt;
begin
     SaveClearFPUState;

     try
        if _CopyBuffer = nil then
        begin
             FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

             Desc.Format           := DXGI_FORMAT_B8G8R8A8_UNORM;
             Desc.Width            := Width;
             Desc.Height           := Height;
             Desc.MipLevels        := 1;
             Desc.ArraySize        := 1;
             Desc.SampleDesc.Count := 1;
             Desc.CPUAccessFlags   := D3D11_CPU_ACCESS_READ;
             Desc.Usage            := D3D11_USAGE_STAGING;

             if Failed( SharedDevice.CreateTexture2D( Desc, nil, _CopyBuffer ) ) then Exit;
        end;

        if Texture = nil then HR := _SwapChain.GetBuffer( 0, ID3D11Texture2D, BackBuffer )
                         else BackBuffer := ResourceToTexture( Texture.Handle );

        SharedContext.CopySubresourceRegion( _CopyBuffer, 0, 0, 0, 0, BackBuffer, 0, nil );

        if Succeeded( SharedContext.Map( _CopyBuffer, 0, D3D11_MAP_READ, 0, Mapped ) ) then
        try
           if ( Rect_.Left = 0 ) and ( Rect_.Top = 0 ) and ( Rect_.Width = Width ) and ( Rect_.Height = Height ) and ( Mapped.RowPitch = Cardinal( Pitch_ ) ) and ( Pitch_ = Width * 4 ) then
           begin
                Move( Mapped.pData^, Bits_^, Pitch_ * Height );
           end
           else
           begin
                for I := Rect_.Top to Rect_.Bottom - 1 do
                begin
                     W := Rect_.Left;

                     Move( PAlphaColorArray( Mapped.pData )[ W + ( I * ( Mapped.RowPitch div 4 ) ) ],
                           PAlphaColorArray( Bits_         )[ I * ( UInt( Pitch_ ) div 4 ) + UInt( Rect_.Left ) ],
                           Rect_.Width * 4 );
                end;
           end;
        finally
               SharedContext.Unmap( _CopyBuffer, 0 );
        end;
     finally
            RestoreFPUState;
     end;
end;

//------------------------------------------------------------------------------

function TLuxDX11Context.DoBeginScene :Boolean;
var
   Viewport :TD3D11_Viewport;
begin
     SaveClearFPUState;

     try
        SharedContext.OMGetRenderTargets( 1, _SavedRT, _SavedDepth );

        SharedContext.RSGetViewports( _SavedViewportNum, nil );

        if _SavedViewportNum > 0 then SharedContext.RSGetViewports( _SavedViewportNum, @_SavedViewport );

        SharedContext.OMSetRenderTargets( 1, _RenderTargetView, _DepthStencilView );

        FillChar( Viewport, SizeOf( D3D11_VIEWPORT ), 0 );

        if Texture <> nil then
        begin
             Viewport.Width  := Width;
             Viewport.Height := Height;
        end
        else
        begin
             Viewport.Width  := Width  * Scale;
             Viewport.Height := Height * Scale;
        end;

        Viewport.MinDepth := 0.0;
        Viewport.MaxDepth := 1.0;

        SharedContext.RSSetViewports( 1, @Viewport );

        Result := inherited;

     finally
            RestoreFPUState;
     end;
end;

procedure TLuxDX11Context.DoEndScene;
begin
     SaveClearFPUState;

     try
        if ( _RenderTargetMSTex <> nil ) and ( Texture <> nil ) then SharedContext.ResolveSubresource( ResourceToTexture( Texture.Handle ), 0, _RenderTargetMSTex, 0, TexturePixelFormatToDX( Texture.PixelFormat ) );

        if ( BeginSceneCount = 1 ) and ( Texture = nil ) then HR := _SwapChain.Present( 0, 0 );

        SharedContext.OMSetRenderTargets( 1, _SavedRT, _SavedDepth );

        _SavedRT := nil;

        _SavedDepth := nil;

        if _SavedViewportNum > 0 then SharedContext.RSSetViewports( 1, @_SavedViewport );

     finally
            RestoreFPUState;
     end;

     inherited;
end;

//------------------------------------------------------------------------------

procedure TLuxDX11Context.DoClear( const Target_:TClearTargets; const Color_:TAlphaColor; const Depth_:Single; const Stencil_:Cardinal );
var
   Flags :TD3D11_CLEAR_FLAG;
begin
     SaveClearFPUState;

     try
        if DepthStencil then
        begin
             Flags := 0;

             if TClearTarget.Depth   in Target_ then Flags := Flags or D3D11_CLEAR_DEPTH  ;
             if TClearTarget.Stencil in Target_ then Flags := Flags or D3D11_CLEAR_STENCIL;

             SharedContext.ClearDepthStencilView( _DepthStencilView, Flags, Depth_, Stencil_ );
        end;

        if ( TClearTarget.Color in Target_ ) and ( _RenderTargetView <> nil ) then SharedContext.ClearRenderTargetView( _RenderTargetView, ColorToD3DColor( Color_ ) );

     finally
            RestoreFPUState;
     end;
end;

procedure TLuxDX11Context.DoSetContextState( State_:TContextState );
begin
     case State_ of
       TContextState.csZTestOn:
          begin
               _DepthStencilDesc.DepthEnable := True;
               _DepthStencilModified         := True;
          end;
       TContextState.csZTestOff:
          begin
               _DepthStencilDesc.DepthEnable := False;
               _DepthStencilModified         := True;
          end;
       TContextState.csZWriteOn:
          begin
               _DepthStencilDesc.DepthWriteMask := D3D11_DEPTH_WRITE_MASK_ALL;
               _DepthStencilModified            := True;
          end;
       TContextState.csZWriteOff:
          begin
               _DepthStencilDesc.DepthWriteMask := D3D11_DEPTH_WRITE_MASK_ZERO;
               _DepthStencilModified            := True;
          end;
       TContextState.csAlphaBlendOn:
          begin
               _BlendDesc.RenderTarget[ 0 ].BlendEnable := True;
               _BlendStateModified                      := True;
          end;
       TContextState.csAlphaBlendOff:
          begin
               _BlendDesc.RenderTarget[ 0 ].BlendEnable := False;
               _BlendStateModified                      := True;
          end;
       TContextState.csStencilOn:
          begin
               _DepthStencilDesc.StencilEnable := True;
               _DepthStencilModified           := True;
          end;
       TContextState.csStencilOff:
          begin
               _DepthStencilDesc.StencilEnable := False;
               _DepthStencilModified           := True;
          end;
       TContextState.csColorWriteOn:
          begin
               _BlendDesc.RenderTarget[ 0 ].RenderTargetWriteMask := Byte( D3D11_COLOR_WRITE_ENABLE_ALL );
               _BlendStateModified                                := True;
          end;
       TContextState.csColorWriteOff:
          begin
               _BlendDesc.RenderTarget[ 0 ].RenderTargetWriteMask := 0;
               _BlendStateModified                                := True;
          end;
       TContextState.csScissorOn:
          begin
               _RasterizerDesc.ScissorEnable := True;
               _RasterizerStateModified      := True;
          end;
       TContextState.csScissorOff:
          begin
               _RasterizerDesc.ScissorEnable := False;
               _RasterizerStateModified      := True;
          end;
       TContextState.csFrontFace:
          begin
               _RasterizerDesc.CullMode := D3D11_CULL_BACK;
               _RasterizerStateModified := True;
          end;
       TContextState.csBackFace:
          begin
               _RasterizerDesc.CullMode := D3D11_CULL_FRONT;
               _RasterizerStateModified := True;
          end;
       TContextState.csAllFace:
          begin
               _RasterizerDesc.CullMode := D3D11_CULL_NONE;
               _RasterizerStateModified := True;
          end;
     end;
end;

procedure TLuxDX11Context.DoSetStencilOp( const Fail_,ZFail_,ZPass_:TStencilOp );
begin
     case Fail_ of
       TStencilOp.Keep    : _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_KEEP    ;
       TStencilOp.Zero    : _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_ZERO    ;
       TStencilOp.Replace : _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_REPLACE ;
       TStencilOp.Increase: _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_INCR_SAT;
       TStencilOp.Decrease: _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_DECR_SAT;
       TStencilOp.Invert  : _DepthStencilDesc.FrontFace.StencilFailOp := D3D11_STENCIL_OP_INVERT  ;
     end;

     case ZFail_ of
       TStencilOp.Keep    : _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_KEEP    ;
       TStencilOp.Zero    : _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_ZERO    ;
       TStencilOp.Replace : _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_REPLACE ;
       TStencilOp.Increase: _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_INCR_SAT;
       TStencilOp.Decrease: _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_DECR_SAT;
       TStencilOp.Invert  : _DepthStencilDesc.FrontFace.StencilDepthFailOp := D3D11_STENCIL_OP_INVERT  ;
     end;

     case ZPass_ of
       TStencilOp.Keep    : _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_KEEP    ;
       TStencilOp.Zero    : _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_ZERO    ;
       TStencilOp.Replace : _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_REPLACE ;
       TStencilOp.Increase: _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_INCR_SAT;
       TStencilOp.Decrease: _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_DECR_SAT;
       TStencilOp.Invert  : _DepthStencilDesc.FrontFace.StencilPassOp := D3D11_STENCIL_OP_INVERT  ;
     end;

     _DepthStencilDesc.BackFace := _DepthStencilDesc.FrontFace;

     _DepthStencilModified := True;
end;

procedure TLuxDX11Context.DoSetStencilFunc( const Func_:TStencilfunc; Ref_,Mask_:Cardinal );
begin
     case Func_ of
       TStencilFunc.Never   : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_NEVER        ;
       TStencilFunc.Less    : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_LESS         ;
       TStencilFunc.Lequal  : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_LESS_EQUAL   ;
       TStencilFunc.Greater : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_GREATER      ;
       TStencilFunc.Gequal  : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_GREATER_EQUAL;
       TStencilFunc.Equal   : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_EQUAL        ;
       TStencilFunc.NotEqual: _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_NOT_EQUAL    ;
       TStencilFunc.Always  : _DepthStencilDesc.FrontFace.StencilFunc := D3D11_COMPARISON_ALWAYS       ;
     end;

     _DepthStencilDesc.StencilReadMask  := Mask_;
     _DepthStencilDesc.StencilWriteMask := Mask_;
     _DepthStencilDesc.BackFace         := _DepthStencilDesc.FrontFace;
     _StencilRef                        := Ref_;
     _DepthStencilModified              := True;
end;

procedure TLuxDX11Context.DoSetScissorRect( const ScissorRect_:TRect );
begin
     SaveClearFPUState;

     try
        _SharedContext.RSSetScissorRects( 1, @ScissorRect_ );

     finally
            RestoreFPUState;
     end;
end;

//------------------------------------------------------------------------------

procedure TLuxDX11Context.DoDrawPrimitivesBatch( const Kind_:TPrimitivesKind; const Vertices_,Indices_:Pointer; const VertexDeclaration_:TVertexDeclaration; const VertexSize_,VertexCount_,IndexSize_,IndexCount_:Integer );
var
   PhysIndexSize, I :Integer;
   VtxStride, VtxOffset :LongWord;
   InputElements :array of TD3D11_INPUT_ELEMENT_DESC;
   Source :TContextShaderSource;
   Flags :TD3D11_Map;
   OldInputLayout :ID3D11InputLayout;
   OldDepthStencilState :ID3D11DepthStencilState;
   OldBlendState :ID3D11BlendState;
   OldRasterizerState :ID3D11RasterizerState;
   OldVSSlot :ID3D11Buffer;
   OldPSSlot :ID3D11Buffer;
   Desc :TD3D11_BUFFER_DESC;
   NeedCreatePS, NeedCreateVS :Boolean;
   Element :TVertexElement;
   Mapped :TD3D11_MAPPED_SUBRESOURCE;
begin
     if CurrentVertexShader <> nil then
     begin
          SaveClearFPUState;

          try
             PhysIndexSize := IndexSize_;

             if ( IndexSize_ = SizeOf( LongInt ) ) and ( IndexBufferSupport <> TIndexBufferSupport.Int32 ) then PhysIndexSize := SizeOf( Word );

             if VertexSize_ * VertexCount_ > VBSize then
             begin
                  _VB := nil;

                  VBSize := VertexSize_ * VertexCount_;

                  HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( VBSize, D3D11_BIND_VERTEX_BUFFER, D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _VB );
             end;

             if _VBLockPos + VertexSize_ * VertexCount_ > VBSize then
             begin
                  _VBLockPos := 0;

                  Flags := D3D11_MAP_WRITE_DISCARD;
             end
             else Flags := D3D11_MAP_WRITE_NO_OVERWRITE;

             if Succeeded( SharedContext.Map( _VB, 0, Flags, 0, Mapped ) ) then
             try
                Move( Vertices_^, PByteArray( Mapped.pData )[ _VBLockPos ], VertexSize_ * VertexCount_ );
             finally
                    SharedContext.Unmap( _VB, 0 );
             end;

             if IndexCount_ * PhysIndexSize > IBSize then
             begin
                  _IB := nil;

                  IBSize := IndexCount_ * PhysIndexSize;

                  HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( IBSize, D3D11_BIND_INDEX_BUFFER, D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _IB );
             end;

             if _IBLockPos + IndexCount_ * PhysIndexSize > IBSize then
             begin
                  _IBLockPos := 0;

                  Flags := D3D11_MAP_WRITE_DISCARD;
             end
             else Flags := D3D11_MAP_WRITE_NO_OVERWRITE;

             if Succeeded( SharedContext.Map( _IB, 0, Flags, 0, Mapped ) ) then
             try
                if PhysIndexSize < IndexSize_ then
                begin
                     for I := 0 to IndexCount_ - 1 do PWord( NativeInt( Mapped.pData ) + _IBLockPos + I * SizeOf( Word ) )^ := PLongInt( NativeInt( Indices_ ) + I * SizeOf( LongInt ) )^;
                end
                else Move( Indices_^, PLongInt( NativeInt( Mapped.pData ) + _IBLockPos )^, IndexCount_ * PhysIndexSize );
             finally
                    SharedContext.Unmap( _IB, 0 );
             end;

             SetLength( InputElements, 0 );

             for Element in VertexDeclaration_ do
             begin
                  case Element.Format of
                    TVertexFormat.Vertex:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'POSITION';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32B32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Normal:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'NORMAL';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32B32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Color0:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'COLOR';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R8G8B8A8_UNORM; // 9_1 doesn't support BGRA
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Color1:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'COLOR';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 1;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R8G8B8A8_UNORM;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Color2:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'COLOR';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 2;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R8G8B8A8_UNORM;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Color3:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'COLOR';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 3;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R8G8B8A8_UNORM;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.TexCoord0:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'TEXCOORD';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.TexCoord1:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'TEXCOORD';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 1;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.TexCoord2:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'TEXCOORD';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 2;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.TexCoord3:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'TEXCOORD';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 3;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.BiNormal:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'BINORMAL';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32B32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.Tangent:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'TANGENT';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32B32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                    TVertexFormat.ColorF0:
                       begin
                            SetLength( InputElements, Length( InputElements ) + 1 );

                            InputElements[ High( InputElements ) ].SemanticName         := 'COLOR';
                            InputElements[ High( InputElements ) ].SemanticIndex        := 0;
                            InputElements[ High( InputElements ) ].Format               := DXGI_FORMAT_R32G32B32A32_FLOAT;
                            InputElements[ High( InputElements ) ].InputSlot            := 0;
                            InputElements[ High( InputElements ) ].AlignedByteOffset    := Element.Offset;
                            InputElements[ High( InputElements ) ].InputSlotClass       := D3D11_INPUT_PER_VERTEX_DATA;
                            InputElements[ High( InputElements ) ].InstanceDataStepRate := 0;
                       end;
                  end;
             end;

             if _VSSlotModified then
             begin
                  NeedCreateVS := Length( _VSBuf ) > 0;

                  if _VSSlot <> nil then
                  begin
                       _VSSlot.GetDesc( Desc );

                       if Desc.ByteWidth = UInt( Length( _VSBuf ) ) then NeedCreateVS := False;
                  end;

                  if NeedCreateVS then
                  begin
                       OldVSSlot := _VSSlot;

                       _VSSlot := nil;

                       HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( Length( _VSBuf ), D3D11_BIND_CONSTANT_BUFFER, D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _VSSlot );
                  end;

                  if _VSSlot <> nil then
                  begin
                       if Succeeded( SharedContext.Map( _VSSlot, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped ) ) then
                       try
                          Move( _VSBuf[ 0 ], Mapped.pData^, Length( _VSBuf ) );
                       finally
                              SharedContext.Unmap( _VSSlot, 0 );
                       end;

                       SharedContext.VSSetConstantBuffers( 0, 1, _VSSlot );
                  end;

                  OldVSSlot := nil;

                  _VSSlotModified := False;
             end;

             if _PSSlotModified then
             begin
                  NeedCreatePS := Length( _PSBuf ) > 0;

                  if _PSSlot <> nil then
                  begin
                       _PSSlot.GetDesc( Desc );

                       if Desc.ByteWidth = UInt( Length( _PSBuf ) ) then NeedCreatePS := False;
                  end;

                  if NeedCreatePS then
                  begin
                       OldPSSlot := _PSSlot;

                       _PSSlot := nil;

                       HR := _SharedDevice.CreateBuffer( TD3D11_BUFFER_DESC.Create( Length( _PSBuf ), D3D11_BIND_CONSTANT_BUFFER, D3D11_USAGE_DYNAMIC, D3D11_CPU_ACCESS_WRITE ), nil, _PSSlot );
                  end;

                  if _PSSlot <> nil then
                  begin
                       if Succeeded( SharedContext.Map( _PSSlot, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped ) ) then
                       try
                          Move( _PSBuf[ 0 ], Mapped.pData^, Length( _PSBuf ) );

                       finally
                              SharedContext.Unmap( _PSSlot, 0 );
                       end;

                       SharedContext.PSSetConstantBuffers( 0, 1, _PSSlot );
                  end;

                  OldPSSlot := nil;

                  _PSSlotModified := False;
             end;

             if _BlendStateModified then
             begin
                  OldBlendState := _BlendState;

                  _BlendState := nil;

                  SharedDevice.CreateBlendState( _BlendDesc, _BlendState );

                  SharedContext.OMSetBlendState( _BlendState, ColorToD3DColor( $FFFFFFFF ), $FFFFFFFF );

                  OldBlendState := nil;

                  _BlendStateModified := False;
             end
             else SharedContext.OMSetBlendState( _BlendState, ColorToD3DColor( $FFFFFFFF ), $FFFFFFFF );

             if _DepthStencilModified then
             begin
                  OldDepthStencilState := _DepthStencilState;

                  _DepthStencilState := nil;

                  SharedDevice.CreateDepthStencilState( _DepthStencilDesc, _DepthStencilState );

                  SharedContext.OMSetDepthStencilState( _DepthStencilState, _StencilRef );

                  OldDepthStencilState := nil;

                  _DepthStencilModified := False;
             end
             else SharedContext.OMSetDepthStencilState( _DepthStencilState, _StencilRef );

             if _RasterizerStateModified then
             begin
                  OldRasterizerState := _RasterizerState;

                  _RasterizerState := nil;

                  SharedDevice.CreateRasterizerState( _RasterizerDesc, _RasterizerState );

                  SharedContext.RSSetState( _RasterizerState );

                  OldRasterizerState := nil;

                  _RasterizerStateModified := False;
             end
             else SharedContext.RSSetState( _RasterizerState );

             FindBestShaderSource( CurrentVertexShader, Source );

             OldInputLayout := _InputLayout;

             _InputLayout := nil;

             HR := SharedDevice.CreateInputLayout( @InputElements[ 0 ], Length( InputElements ), @Source.Code[ 0 ], Length( Source.Code ), _InputLayout );

             if Succeeded( HR ) then
             begin
                  VtxStride := VertexSize_;

                  VtxOffset := _VBLockPos;

                  SharedContext.IASetVertexBuffers( 0, 1, _VB, @VtxStride, @VtxOffset );

                  SharedContext.IASetInputLayout( _InputLayout );

                  if PhysIndexSize = SizeOf( LongInt ) then SharedContext.IASetIndexBuffer( _IB, DXGI_FORMAT_R32_UINT, _IBLockPos )
                                                       else SharedContext.IASetIndexBuffer( _IB, DXGI_FORMAT_R16_UINT, _IBLockPos );

                  case Kind_ of
                    TPrimitivesKind.Points: SharedContext.IASetPrimitiveTopology( D3D11_PRIMITIVE_TOPOLOGY_POINTLIST    );
                    TPrimitivesKind.Lines : SharedContext.IASetPrimitiveTopology( D3D11_PRIMITIVE_TOPOLOGY_LINELIST     );
                  else                      SharedContext.IASetPrimitiveTopology( D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST );
                  end;

                  SharedContext.DrawIndexed( IndexCount_, 0, 0 );

                  OldInputLayout := nil;
             end;

             _VBLockPos := _VBLockPos + VertexSize_ * VertexCount_;

             _IBLockPos := _IBLockPos + IndexCount_ * PhysIndexSize;

          finally
                 RestoreFPUState;
          end;
     end;
end;

//------------------------------------------------------------------------------

class procedure TLuxDX11Context.DoInitializeTexture( const Texture_:TTexture );
begin
     if Texture_ is TTexture3D then DoInitializeTexture3D( Texture_ as TTexture3D )
                               else DoInitializeTexture2D( Texture_ );
end;

class procedure TLuxDX11Context.DoInitializeTexture2D( const Texture_:TTexture );
var
   Tex :ID3D11Texture2D;
   Desc :TD3D11_TEXTURE2D_DESC;
begin
     CreateSharedDevice;

     FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

     if Texture_.PixelFormat = TPixelFormat.None then Texture_.PixelFormat := TPixelFormat.BGRA;

     Desc.Format := TexturePixelFormatToDX( Texture_.PixelFormat );
     Desc.Width  := Texture_.Width;
     Desc.Height := Texture_.Height;

     if TTextureStyle.MipMaps in Texture_.Style then
     begin
          if TTextureStyle.Dynamic in Texture_.Style then Desc.MipLevels := 1
                                                     else Desc.MipLevels := 0;
     end
     else Desc.MipLevels := 1;

     Desc.ArraySize          := 1;
     Desc.SampleDesc.Count   := 1;
     Desc.SampleDesc.Quality := 0;

     if ( TTextureStyle.Dynamic in Texture_.Style ) and not ( TTextureStyle.RenderTarget in Texture_.Style ) then
     begin
          Desc.CPUAccessFlags := D3D11_CPU_ACCESS_WRITE;
          Desc.Usage          := D3D11_USAGE_DYNAMIC;
     end
     else Desc.Usage := D3D11_USAGE_DEFAULT;

     Desc.BindFlags := D3D11_BIND_SHADER_RESOURCE;

     if TTextureStyle.RenderTarget in Texture_.Style then Desc.BindFlags := Desc.BindFlags or D3D11_BIND_RENDER_TARGET;

     SaveClearFPUState;

     try
        HR := SharedDevice.CreateTexture2D( Desc, nil, Tex );

     finally
            RestoreFPUState;
     end;

     if Tex <> nil then ITextureAccess( Texture_ ).Handle := AddResource( Tex );
end;

class procedure TLuxDX11Context.DoInitializeTexture3D( const Texture_:TTexture3D );
var
   Tex :ID3D11Texture3D;
   Desc :TD3D11_TEXTURE3D_DESC;
begin
     CreateSharedDevice;

     FillChar( Desc, SizeOf( D3D11_TEXTURE3D_DESC ), 0 );

     if Texture_.PixelFormat = TPixelFormat.None then Texture_.PixelFormat := TPixelFormat.BGRA;

     Desc.Format := TexturePixelFormatToDX( Texture_.PixelFormat );
     Desc.Width  := Texture_.Width;
     Desc.Height := Texture_.Height;
     Desc.Depth  := Texture_.Depth;

     if TTextureStyle.MipMaps in Texture_.Style then
     begin
          if TTextureStyle.Dynamic in Texture_.Style then Desc.MipLevels := 1
                                                     else Desc.MipLevels := 0;
     end
     else Desc.MipLevels := 1;

     if ( TTextureStyle.Dynamic in Texture_.Style ) and not ( TTextureStyle.RenderTarget in Texture_.Style ) then
     begin
          Desc.CPUAccessFlags := D3D11_CPU_ACCESS_WRITE;
          Desc.Usage          := D3D11_USAGE_DYNAMIC;
     end
     else Desc.Usage := D3D11_USAGE_DEFAULT;

     Desc.BindFlags := D3D11_BIND_SHADER_RESOURCE;

     if TTextureStyle.RenderTarget in Texture_.Style then Desc.BindFlags := Desc.BindFlags or D3D11_BIND_RENDER_TARGET;

     SaveClearFPUState;

     try
        HR := SharedDevice.CreateTexture3D( @Desc, nil, Tex );

     finally
            RestoreFPUState;
     end;

     if Tex <> nil then ITextureAccess( Texture_ ).Handle := AddResource( Tex );
end;

class procedure TLuxDX11Context.DoFinalizeTexture( const Texture_:TTexture );
begin
     SaveClearFPUState;

     try
        RemoveResource( Texture_.Handle );

        ITextureAccess( Texture_ ).Handle := 0;

     finally
            RestoreFPUState;
     end;
end;

class procedure TLuxDX11Context.DoUpdateTexture( const Texture_:TTexture; const Bits_:Pointer; const Pitch_:Integer );
begin
     if Texture_ is TTexture3D then DoUpdateTexture3D( Texture_ as TTexture3D )
                               else DoUpdateTexture2D( Texture_, Bits_, Pitch_ );
end;

class procedure TLuxDX11Context.DoUpdateTexture2D( const Texture_:TTexture; const Bits_:Pointer; const Pitch_:Integer );
var
   Mapped :D3D11_MAPPED_SUBRESOURCE;
   I, BytesToCopy :UInt;
   CopyBuffer, Tex :ID3D11Texture2D;
   Desc :TD3D11_TEXTURE2D_DESC;
begin
     if ( Texture_ <> nil ) and ( Texture_.Handle <> 0 ) then
     begin
          SaveClearFPUState;

          try
             Tex := ResourceToTexture( Texture_.Handle );

             if TTextureStyle.RenderTarget in Texture_.Style then
             begin
                  FillChar( Desc, SizeOf( D3D11_TEXTURE2D_DESC ), 0 );

                  Desc.Format             := TexturePixelFormatToDX( Texture_.PixelFormat ); //DXGI_FORMAT_B8G8R8A8_UNORM
                  Desc.Width              := Texture_.Width;
                  Desc.Height             := Texture_.Height;
                  Desc.MipLevels          := 1;
                  Desc.ArraySize          := 1;
                  Desc.SampleDesc.Count   := 1;
                  Desc.SampleDesc.Quality := 0;
                  Desc.CPUAccessFlags     := D3D11_CPU_ACCESS_WRITE;
                  Desc.Usage              := D3D11_USAGE_STAGING;
                  Desc.BindFlags          := 0;

                  HR := SharedDevice.CreateTexture2D( Desc, nil, CopyBuffer );

                  if Succeeded( SharedContext.Map( CopyBuffer, 0, D3D11_MAP_WRITE, 0, Mapped ) ) then
                  try
                     if UInt( Pitch_ ) = Mapped.RowPitch then Move( Bits_^, Mapped.pData^, Texture_.Height * Pitch_ )
                     else
                     begin
                          BytesToCopy := Min( Pitch_, Mapped.RowPitch );

                          for I := 0 to Texture_.Height - 1 do Move( PByteArray( Bits_        )[ UInt( Pitch_ )  * I ],
                                                                     PByteArray( Mapped.pData )[ Mapped.RowPitch * I ],
                                                                     BytesToCopy );
                     end;
                  finally
                         SharedContext.Unmap( CopyBuffer, 0 );
                  end;

                  SharedContext.CopySubresourceRegion( Tex, 0, 0, 0, 0, CopyBuffer, 0, nil );
             end
             else
             begin
                  if Succeeded( SharedContext.Map( Tex, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped ) ) then
                  try
                     if UInt( Pitch_ ) = Mapped.RowPitch then Move( Bits_^, Mapped.pData^, Texture_.Height * Pitch_ )
                     else
                     begin
                          BytesToCopy := Min( Pitch_, Mapped.RowPitch );

                          for I := 0 to Texture_.Height - 1 do Move( PByteArray( Bits_        )[ UInt( Pitch_ )  * I ],
                                                                     PByteArray( Mapped.pData )[ Mapped.RowPitch * I ],
                                                                     BytesToCopy );
                     end;
                  finally
                         SharedContext.Unmap( Tex, 0 );
                  end;
             end;
          finally
                 RestoreFPUState;
          end;
     end;
end;

class procedure TLuxDX11Context.DoUpdateTexture3D( const Texture_:TTexture3D );
var
   Mapped :D3D11_MAPPED_SUBRESOURCE;
   Y, Z :UInt;
   CopyBuffer, Tex :ID3D11Texture3D;
   Desc :TD3D11_TEXTURE3D_DESC;
begin
     if ( Texture_ <> nil ) and ( Texture_.Handle <> 0 ) then
     begin
          SaveClearFPUState;
          try
             Tex := ResourceToTexture3D( Texture_.Handle );

             if TTextureStyle.RenderTarget in Texture_.Style then
             begin
                  FillChar( Desc, SizeOf( D3D11_TEXTURE3D_DESC ), 0 );

                  Desc.Format         := TexturePixelFormatToDX( Texture_.PixelFormat );
                  Desc.Width          := Texture_.Width;
                  Desc.Height         := Texture_.Height;
                  Desc.Depth          := Texture_.Depth;
                  Desc.MipLevels      := 1;
                  Desc.CPUAccessFlags := D3D11_CPU_ACCESS_WRITE;
                  Desc.Usage          := D3D11_USAGE_STAGING;
                  Desc.BindFlags      := 0;

                  HR := SharedDevice.CreateTexture3D( @Desc, nil, CopyBuffer );

                  if Succeeded( SharedContext.Map( CopyBuffer, 0, D3D11_MAP_WRITE, 0, Mapped ) ) then
                  try
                     with Texture_.Map do
                     begin
                          for Z := 0 to ItemsZ-1 do
                          begin
                               for Y := 0 to ItemsY-1 do
                               begin
                                    Move( Lines[ Y, Z ]^,
                                          PByteArray( Mapped.pData )[ Mapped.DepthPitch * Z
                                                                    + Mapped.RowPitch   * Y ],
                                          LineSize );
                               end;
                          end;
                     end;
                  finally
                         SharedContext.Unmap( CopyBuffer, 0 );
                  end;

                  SharedContext.CopySubresourceRegion( Tex, 0, 0, 0, 0, CopyBuffer, 0, nil );
             end
             else
             begin
                  if Succeeded( SharedContext.Map( Tex, 0, D3D11_MAP_WRITE_DISCARD, 0, Mapped ) ) then
                  try
                     with Texture_.Map do
                     begin
                          for Z := 0 to ItemsZ-1 do
                          begin
                               for Y := 0 to ItemsY-1 do
                               begin
                                    Move( Lines[ Y, Z ]^,
                                          PByteArray( Mapped.pData )[ Mapped.DepthPitch * Z
                                                                    + Mapped.RowPitch   * Y ],
                                          LineSize );
                               end;
                          end;
                     end;
                  finally
                         SharedContext.Unmap( Tex, 0 );
                  end;
             end;
          finally
                 RestoreFPUState;
          end;
     end;
end;

//------------------------------------------------------------------------------

class function TLuxDX11Context.DoBitmapToTexture( const Bitmap_:TBitmap ) :TTexture;
begin
     if Bitmap_.CanvasClass.InheritsFrom( TCustomCanvasGpu ) then Result := TBitmapCtx( Bitmap_.Handle ).PaintingTexture
                                                             else Result := inherited DoBitmapToTexture( Bitmap_ );
end;

//------------------------------------------------------------------------------

class procedure TLuxDX11Context.DoInitializeShader( const Shader_:TContextShader );
var
   VSShader :ID3D11VertexShader;
   PSShader :ID3D11PixelShader;
   Source :TContextShaderSource;
begin
     CreateSharedDevice;

     FindBestShaderSource( Shader_, Source );

     if Source.IsDefined then
     begin
          SaveClearFPUState;

          try
             if Shader_.Kind = TContextShaderKind.VertexShader then
             begin
                  HR := SharedDevice.CreateVertexShader( Source.Code, Length( Source.Code ), nil, @VSShader );

                  if VSShader <> nil then Shader_.Handle := AddResource( VSShader );
             end
             else
             begin
                  HR := SharedDevice.CreatePixelShader( Source.Code, Length( Source.Code ), nil, PSShader );

                  if PSShader <> nil then Shader_.Handle := AddResource( PSShader );
             end;
          finally
                 RestoreFPUState;
          end;
     end;
end;

class procedure TLuxDX11Context.DoFinalizeShader( const Shader_:TContextShader );
begin
     SaveClearFPUState;

     try
        RemoveResource( Shader_.Handle );

     finally
            RestoreFPUState;
     end;

     Shader_.Handle := 0;
end;

procedure TLuxDX11Context.DoSetShaders( const VertexShader_,PixelShader_:TContextShader );
var
   Source :TContextShaderSource;
begin
     SaveClearFPUState;

     try
        SharedContext.VSSetShader( ResourceToVertexShader( VertexShader_.Handle ), nil, 0 );
        SharedContext.PSSetShader( ResourceToPixelShader ( PixelShader_ .Handle ), nil, 0 );

     finally
            RestoreFPUState;
     end;

     if VertexShader_ <> nil then
     begin
          FindBestShaderSource( VertexShader_, Source );

          SetLength( _VSBuf, GetSlotSize( Source ) );

          _VSSlotModified := True;
     end;

     if PixelShader_ <> nil then
     begin
          FindBestShaderSource( PixelShader_, Source );

          SetLength( _PSBuf, GetSlotSize( Source ) );

          _PSSlotModified := True;
     end;
end;

procedure TLuxDX11Context.DoSetShaderVariable( const Name_:string; const Data_:array of TVector3D );
var
   I :Integer;
   Source :TContextShaderSource;
begin
     if ( CurrentVertexShader <> nil ) and ( Length( _VSBuf ) > 0 ) then
     begin
          FindBestShaderSource( CurrentVertexShader, Source );

          for I := 0 to High( Source.Variables ) do
          begin
               if SameText( Source.Variables[I].Name, Name_ ) then
               begin
                    Move( Data_[ 0 ], _VSBuf[ Source.Variables[ I ].Index ], Min( SizeOf( Data_ ), Source.Variables[ I ].Size ) );

                    _VSSlotModified := True;

                    Break;
               end;
          end;
     end;

     if ( CurrentPixelShader <> nil ) and ( Length( _PSBuf ) > 0 ) then
     begin
          FindBestShaderSource( CurrentPixelShader, Source );

          for I := 0 to High( Source.Variables ) do
          begin
               if SameText( Source.Variables[ I ].Name, Name_ ) then
               begin
                    Move( Data_[ 0 ], _PSBuf[ Source.Variables[ I ].Index ], Min( SizeOf( Data_ ), Source.Variables[ I ].Size ) );

                    _PSSlotModified := True;

                    Break;
               end;
          end;
     end;
end;

procedure TLuxDX11Context.DoSetShaderVariable( const Name_:string; const Texture_:TTexture );
var
   I :Integer;
   Source :TContextShaderSource;
begin
     if CurrentPixelShader <> nil then
     begin
          FindBestShaderSource( CurrentPixelShader, Source );

          for I := 0 to High( Source.Variables ) do
          begin
               if SameText( Source.Variables[ I ].Name, Name_ ) then
               begin
                    SetTexture( Source.Variables[ I ].Index, Texture_ );

                    Exit;
               end;
          end;
     end;
end;

procedure TLuxDX11Context.DoSetShaderVariable( const Name_:string; const Matrix_:TMatrix3D );
begin
     SetShaderVariable( Name_, Matrix_.M );
end;

//------------------------------------------------------------------------------

constructor TLuxDX11Context.CreateFromWindow( const Parent_:TWindowHandle; const Width_,Height_:Integer; const Multisample_:TMultisample; const DepthStencil_:Boolean );
begin
     inherited;

     CreateSharedDevice;

     CreateBuffer;
end;

constructor TLuxDX11Context.CreateFromTexture( const Texture_:TTexture; const Multisample_:TMultisample; const DepthStencil_:Boolean );
begin
     inherited;

     CreateSharedDevice;

     CreateBuffer;
end;

class function TLuxDX11Context.PixelFormat :TPixelFormat;
begin
     Result := TPixelFormat.BGRA;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

//############################################################################## □

procedure RegisterContextClasses;
var
   DriverType :D3D_DRIVER_TYPE;
   FeatureLevel :TD3D_FEATURE_LEVEL;
begin
     TLuxCustomDX11Context.TestDriverSupport( DriverType, FeatureLevel );

     if DriverType <> D3D_DRIVER_TYPE_NULL then TContextManager.RegisterContext( TLuxDX11Context, True );
end;

procedure UnregisterContextClasses;
begin
     TLuxDX11Context.DestroySharedDevice;
end;

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     RegisterContextClasses;

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

     UnregisterContextClasses;

end. //######################################################################### ■
