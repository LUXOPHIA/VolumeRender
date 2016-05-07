unit LUX.FMX.Material;

interface //#################################################################### ■

uses FMX.Types3D, System.Classes, System.UITypes, System.Generics.Collections,
     System.Math.Vectors,
     FMX.MaterialSources,
     Winapi.D3DCommon, Winapi.D3D11Shader, Winapi.D3DCompiler,
     LUX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TShaderVar            = class;
       TShaderVarPrim      = class;
         TShaderVarFloat   = class;
         TShaderVarFloat2  = class;
         TShaderVarFloat3  = class;
         TShaderVarVector  = class;
         TShaderVarColor   = class;
         TShaderVarMatrix  = class;
         TShaderVarTexture = class;
       TShaderVarLights    = class;
     TShaderSource         = class;

     TLuxMaterial          = class;

     ///////////////////////////////////////////////////////////////////////////

     TShaderVars = array of TShaderVar;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVar

     TShaderVar = class
     private
     protected
       _Name :String;
       ///// アクセス
       function GetSize :Integer; virtual; abstract;
     public
       constructor Create( const Name_:String );
       ///// プロパティ
       property Name :String  read   _Name write _Name;
       property Size :Integer read GetSize;
       ///// メソッド
       function AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables; virtual; abstract;
       procedure SendVar( const Context_:TContext3D ); virtual; abstract;
       function GetSource(  var I_:Integer ) :String; virtual; abstract;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPrim

     TShaderVarPrim = class( TShaderVar )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; virtual; abstract;
     public
       ///// プロパティ
       property Kind :TContextShaderVariableKind read GetKind;
       ///// メソッド
       function AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat

     TShaderVarFloat = class( TShaderVarPrim )
     private
     protected
       _Value :Single;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :Single read _Value write _Value;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat2

     TShaderVarFloat2 = class( TShaderVarPrim )
     private
     protected
       _Value1 :Single;
       _Value2 :Single;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value1 :Single read _Value1 write _Value1;
       property Value2 :Single read _Value2 write _Value2;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat3

     TShaderVarFloat3 = class( TShaderVarPrim )
     private
     protected
       _Value1 :Single;
       _Value2 :Single;
       _Value3 :Single;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value1 :Single read _Value1 write _Value1;
       property Value2 :Single read _Value2 write _Value2;
       property Value3 :Single read _Value3 write _Value3;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarVector

     TShaderVarVector = class( TShaderVarPrim )
     private
     protected
       _Value :TVector3D;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :TVector3D read _Value write _Value;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarColor

     TShaderVarColor = class( TShaderVarPrim )
     private
     protected
       _Value :TAlphaColor;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :TAlphaColor read _Value write _Value;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarMatrix

     TShaderVarMatrix = class( TShaderVarPrim )
     private
     protected
       _Value :TMatrix3D;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :TMatrix3D read _Value write _Value;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarTexture

     TShaderVarTexture = class( TShaderVarPrim )
     private
     protected
[Weak] _Value :TTexture;
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :TTexture read _Value write _Value;
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables; override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarLights

     TShaderVarLights = class( TShaderVar )
     private
     protected
       _Value :TLightDescription;
       ///// アクセス
       function GetSize :Integer; override;
     public
       ///// プロパティ
       property Value :TLightDescription read _Value write _Value;
       ///// メソッド
       function AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables; override;
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource(  var I_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSource

     TShaderSource = class
     private
     protected
       _Name    :String;
       _Shader  :TContextShader;
       _Vars    :TShaderVars;
       _Entry   :AnsiString;
       _Source  :TStringList;
       _Targets :TDictionary<TContextShaderArch,AnsiString>;
       _Errors  :TDictionary<AnsiString,AnsiString>;
       ///// アクセス
       function GetKind :TContextShaderKind; virtual; abstract;
       procedure SetSource( Sender_:TObject );
     public
       constructor Create;
       destructor Destroy; override;
       ///// プロパティ
       property Name   :String             read   _Name   write _Name  ;
       property Shader :TContextShader     read   _Shader write _Shader;
       property Kind   :TContextShaderKind read GetKind                ;
       property Vars   :TShaderVars        read   _Vars   write _Vars  ;
       property Entry  :AnsiString         read   _Entry  write _Entry ;
       property Source :TStringList        read   _Source              ;
       ///// メソッド
       procedure LoadFromFile( const Name_:String );
       procedure LoadFromStream( const Stream_:TStream );
       procedure LoadFromResource( const Name_:String );
       function CSV( const A_:TContextShaderArch ) :TContextShaderVariables;
       procedure Compile;
       procedure SendVars( const Context_:TContext3D );
       function GetSources :String;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSourceV

     TShaderSourceV = class( TShaderSource )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderKind; override;
     public
       constructor Create;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSourceP

     TShaderSourceP = class( TShaderSource )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderKind; override;
     public
       constructor Create;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TLuxMaterial

     TLuxMaterial = class( TMaterial )
     private
     protected
       _ShaderV :TShaderSourceV;
       _ShaderP :TShaderSourceP;
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property ShaderV :TShaderSourceV read _ShaderV;
       property ShaderP :TShaderSourceP read _ShaderP;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMaterialSource<_TMaterial_>

     TLuxMaterialSource<_TMaterial_:TLuxMaterial> = class( TMaterialSource )
     private
       ///// アクセス
       function GetMaterial :_TMaterial_;
     protected
       ///// アクセス
       function GetShaderV :TShaderSourceV;
       function GetShaderP :TShaderSourceP;
       ///// プロパティ
       property _Material :_TMaterial_ read GetMaterial;
       ///// メソッド
       function CreateMaterial: TMaterial; override;
     public
       ///// プロパティ
       property ShaderV :TShaderSourceV read GetShaderV;
       property ShaderP :TShaderSourceP read GetShaderP;
     end;

const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

      VARUNIT :array [ TContextShaderArch ] of Byte = (  1,    // Undefined,
                                                         1,    // DX9,
                                                        16,    // DX10,
                                                        16,    // DX11_level_9,
                                                        16,    // DX11,
                                                         1,    // GLSL,
                                                         1,    // Mac,
                                                         1,    // IOS,
                                                         1 );  // Android

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.Types, System.SysUtils, System.IOUtils, System.Math;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVar

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TShaderVar.Create( const Name_:String );
begin
     inherited Create;

     _Name := Name_;
end;

/////////////////////////////////////////////////////////////////////// メソッド

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPrim

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarPrim.AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( Name, Kind, I_, U_ * Size ) ];

     Inc( I_, U_ * Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarFloat.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float;
end;

function TShaderVarFloat.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarFloat.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value, 0, 0, 0 ) ] );
end;

function TShaderVarFloat.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat2

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarFloat2.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float2;
end;

function TShaderVarFloat2.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarFloat2.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value1, _Value2, 0, 0 ) ] );
end;

function TShaderVarFloat2.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float2 ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarFloat3

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarFloat3.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float3;
end;

function TShaderVarFloat3.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarFloat3.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value1, _Value2, _Value3, 0 ) ] );
end;

function TShaderVarFloat3.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float3 ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarVector

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarVector.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Vector;
end;

function TShaderVarVector.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarVector.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarVector.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float4 ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarColor

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarColor.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Vector;
end;

function TShaderVarColor.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarColor.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarColor.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float4 ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarMatrix

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarMatrix.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Matrix;
end;

function TShaderVarMatrix.GetSize :Integer;
begin
     Result := 4;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarMatrix.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarMatrix.GetSource(  var I_:Integer ) :String;
begin
     Result := 'float4x4 ' + _Name + ' : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarTexture

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarTexture.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Texture;
end;

function TShaderVarTexture.GetSize :Integer;
begin
     Result := 0;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarTexture.AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( Name, Kind, 0, 0 ) ];
end;

procedure TShaderVarTexture.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarTexture.GetSource(  var I_:Integer ) :String;
begin
     Result := 'Texture2D<float4> ' + _Name + ' : register( t0 );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarLights

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarLights.GetSize :Integer;
begin
     Result := 4;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarLights.AddVar( var I_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( 'Lights[0].Opt', TContextShaderVariableKind.Vector, I_+0*U_, U_ ),
                 TContextShaderVariable.Create( 'Lights[0].Pos', TContextShaderVariableKind.Vector, I_+1*U_, U_ ),
                 TContextShaderVariable.Create( 'Lights[0].Dir', TContextShaderVariableKind.Vector, I_+2*U_, U_ ),
                 TContextShaderVariable.Create( 'Lights[0].Col', TContextShaderVariableKind.Vector, I_+3*U_, U_ ) ];

     Inc( I_, U_ * Size );
end;

procedure TShaderVarLights.SendVar( const Context_:TContext3D );
begin
     with _Value do
     begin
          with Context_ do
          begin
               SetShaderVariable( 'Lights[0].Opt', [ TVector3D.Create( Integer( LightType ) + 1     ,
                                                                       Cos( DegToRad( SpotCutoff ) ),
                                                                       SpotExponent                 ,
                                                                       0                             ) ] );
               SetShaderVariable( 'Lights[0].Pos', [ Position ]                                                                                     );
               SetShaderVariable( 'Lights[0].Dir', [ Direction ]                                                                                    );
               SetShaderVariable( 'Lights[0].Col', Color                                                                                            );
          end;
     end;
end;

function TShaderVarLights.GetSource(  var I_:Integer ) :String;
begin
     Result := 'struct TLight'                                               + #13#10
             + '{'                                                           + #13#10
             + '    float4 Opt;'                                             + #13#10
             + '    float4 Pos;'                                             + #13#10
             + '    float4 Dir;'                                             + #13#10
             + '    float4 Col;'                                             + #13#10
             + '};'                                                          + #13#10
             + 'TLight ' + _Name + '[1] : register( c' + I_.ToString + ' );' + #13#10;

     Inc( I_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSource

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

procedure TShaderSource.SetSource( Sender_:TObject );
begin
     Compile;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TShaderSource.Create;
begin
     inherited;

     _Source := TStringList.Create;
     _Source.OnChange := SetSource;

     _Targets := TDictionary<TContextShaderArch,AnsiString>.Create;
     _Errors  := TDictionary<AnsiString,AnsiString>.Create;
end;

destructor TShaderSource.Destroy;
begin
     _Errors .Free;
     _Targets.Free;

     _Source.Free;

     inherited;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TShaderSource.LoadFromFile( const Name_:String );
begin
     _Source.LoadFromFile( Name_ );

     _Name := TPath.GetFileName( Name_ );

     Compile;
end;

procedure TShaderSource.LoadFromStream( const Stream_:TStream );
begin
     _Source.LoadFromStream( Stream_ );

     _Name := '';

     Compile;
end;

procedure TShaderSource.LoadFromResource( const Name_:String );
var
   RS :TResourceStream;
begin
     RS := TResourceStream.Create( HInstance, Name_, RT_RCDATA );

     LoadFromStream( RS );

     RS.Free;

     _Name := Name_;
end;

////////////////////////////////////////////////////////////////////////////////

function TShaderSource.CSV( const A_:TContextShaderArch ) :TContextShaderVariables;
var
   V :TShaderVar;
   I :Integer;
begin
     Result := [];  I := 0;

     for V in _Vars do Result := Result + V.AddVar( I, VARUNIT[ A_ ] );
end;

procedure TShaderSource.Compile;
var
   S, N, T :AnsiString;
   CSS :array of TContextShaderSource;
   A :TContextShaderArch;
   H :HResult;
   B, E :ID3DBlob;
   C :TArray<Byte>;
begin
     TShaderManager.UnregisterShader( _Shader );

     S := AnsiString( GetSources + _Source.Text );
     N := AnsiString( _Name );

     CSS := [];

     for A in _Targets.Keys do
     begin
          T := _Targets.Items[ A ];

          H := D3DCompile( PAnsiChar( S )     ,
                           Length( S )        ,
                           PAnsiChar( N )     ,
                           nil                ,
                           nil                ,
                           PAnsiChar( _Entry ),
                           PAnsiChar( T )     ,
                           0                  ,
                           0                  ,
                           B                  ,
                           E                   );

          if not Assigned( B ) then
          begin
               _Errors.Add( T, AnsiString( E.GetBufferPointer ) );

               Exit;
          end;

          SetLength( C, B.GetBufferSize );
          Move( B.GetBufferPointer^, C[0], B.GetBufferSize );

          CSS := CSS + [ TContextShaderSource.Create( A, C, CSV( A ) ) ];
     end;

     _Shader := TShaderManager.RegisterShaderFromData( _Name, GetKind, '', CSS );
end;

procedure TShaderSource.SendVars( const Context_:TContext3D );
var
   V :TShaderVar;
begin
     for V in _Vars do V.SendVar( Context_ );
end;

function TShaderSource.GetSources :String;
var
   V :TShaderVar;
   C :Integer;
begin
     Result := '';  C := 0;

     for V in _Vars do Result := Result + V.GetSource( C );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSourceV

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderSourceV.GetKind :TContextShaderKind;
begin
     Result := TContextShaderKind.VertexShader;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TShaderSourceV.Create;
begin
     inherited;

     _Entry := 'MainV';

     _Targets.Add( TContextShaderArch.DX9         , 'vs_3_0'           );
     _Targets.Add( TContextShaderArch.DX11_level_9, 'vs_4_0_level_9_3' );
     _Targets.Add( TContextShaderArch.DX11        , 'vs_5_0'           );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderSourceP

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderSourceP.GetKind :TContextShaderKind;
begin
     Result := TContextShaderKind.PixelShader;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TShaderSourceP.Create;
begin
     inherited;

     _Entry := 'MainP';

     _Targets.Add( TContextShaderArch.DX9         , 'ps_3_0'           );
     _Targets.Add( TContextShaderArch.DX11_level_9, 'ps_4_0_level_9_3' );
     _Targets.Add( TContextShaderArch.DX11        , 'ps_5_0'           );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TLuxMaterial

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TLuxMaterial.Create;
begin
     inherited;

     _ShaderV := TShaderSourceV.Create;
     _ShaderP := TShaderSourceP.Create;
end;

destructor TLuxMaterial.Destroy;
begin
     _ShaderV.Free;
     _ShaderP.Free;

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TLuxMaterialSource<_TMaterial_>

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// アクセス

function TLuxMaterialSource<_TMaterial_>.GetMaterial :_TMaterial_;
begin
     Result := _TMaterial_( Material );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TLuxMaterialSource<_TMaterial_>.GetShaderV :TShaderSourceV;
begin
     Result := _Material.ShaderV;
end;

function TLuxMaterialSource<_TMaterial_>.GetShaderP :TShaderSourceP;
begin
     Result := _Material.ShaderP;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TLuxMaterialSource<_TMaterial_>.CreateMaterial: TMaterial;
begin
     Result := _TMaterial_.Create;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
