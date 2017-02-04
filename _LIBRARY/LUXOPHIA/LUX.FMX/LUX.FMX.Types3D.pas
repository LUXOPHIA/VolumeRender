unit LUX.FMX.Types3D;

interface //#################################################################### ■

uses System.UITypes, System.Messaging,
     FMX.Types3D,
     LUX, LUX.Lattice.T3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3D

     TTexture3D = class( TTexture )
     private
       _ContextLostId              :Integer;
       _ContextResetId             :Integer;
       _RequireInitializeAfterLost :Boolean;
     protected
       _Map :TArray3D;
       ///// アクセス
       function GetWidth :Integer;
       procedure SetWidth( const Width_:Integer );
       function GetHeight :Integer;
       procedure SetHeight( const Height_:Integer );
       function GetDepth :Integer;
       procedure SetDepth( const Depth_:Integer );
       ///// メソッド
       procedure ContextLostHandler( const Sender:TObject; const Msg:TMessage );
       procedure ContextResetHandler( const Sender:TObject; const Msg:TMessage );
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Map    :TArray3D read   _Map                   ;
       property Width  :Integer  read GetWidth  write SetWidth ;
       property Height :Integer  read GetHeight write SetHeight;
       property Depth  :Integer  read GetDepth  write SetDepth ;
       ///// メソッド
       function IsEmpty :Boolean;
       procedure UpdateTexture;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3DBGRA

     TTexture3DBGRA = class( TTexture3D )
     private
     protected
       ///// アクセス
       function GetMap :TArray3D<TAlphaColor>;
       function GetPixels( const X_,Y_,Z_:Integer ) :TAlphaColor;
       procedure SetPixels( const X_,Y_,Z_:Integer; const Pixel_:TAlphaColor );
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Map                              :TArray3D<TAlphaColor> read GetMap                   ;
       property Pixels[ const X_,Y_,Z_:Integer ] :TAlphaColor           read GetPixels write SetPixels;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses FMX.Types;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TTexture3D.GetWidth :Integer;
begin
     Result := _Map.CountX;
end;

procedure TTexture3D.SetWidth( const Width_:Integer );
begin
     inherited Width := Width_;

     _Map.CountX := Width_;
end;

function TTexture3D.GetHeight :Integer;
begin
     Result := _Map.CountY;
end;

procedure TTexture3D.SetHeight( const Height_:Integer );
begin
     inherited Height := Height_;

     _Map.CountY := Height_;
end;

function TTexture3D.GetDepth :Integer;
begin
     Result := _Map.CountZ;
end;

procedure TTexture3D.SetDepth( const Depth_:Integer );
begin
     Finalize;

     _Map.CountZ := Depth_;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TTexture3D.ContextLostHandler( const Sender:TObject; const Msg:TMessage );
begin
     if not ( TTextureStyle.Volatile in Style ) then
     begin
          if Handle <> 0 then _RequireInitializeAfterLost := True;

          Finalize;
     end;
end;

procedure TTexture3D.ContextResetHandler( const Sender:TObject; const Msg:TMessage );
begin
     if not ( TTextureStyle.Volatile in Style ) then
     begin
          if _RequireInitializeAfterLost then Initialize;

          _RequireInitializeAfterLost := False;

          UpdateTexture;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTexture3D.Create;
begin
     inherited;

     _ContextLostId  := TMessageManager.DefaultManager.SubscribeToMessage( TContextLostMessage , ContextLostHandler  );
     _ContextResetId := TMessageManager.DefaultManager.SubscribeToMessage( TContextResetMessage, ContextResetHandler );
end;

destructor TTexture3D.Destroy;
begin
     TMessageManager.DefaultManager.Unsubscribe( TContextLostMessage , _ContextLostId  );
     TMessageManager.DefaultManager.Unsubscribe( TContextResetMessage, _ContextResetId );

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TTexture3D.IsEmpty: Boolean;
begin
     Result := ( Width * Height * Depth = 0 );
end;

procedure TTexture3D.UpdateTexture;
begin
     if Assigned( _Map ) then TContextManager.DefaultContextClass.UpdateTexture( Self, _Map.Lines[ 0, 0 ], _Map.StepY );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3DBGRA

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

function TTexture3DBGRA.GetMap :TArray3D<TAlphaColor>;
begin
     Result := _Map as TArray3D<TAlphaColor>;
end;

//------------------------------------------------------------------------------

function TTexture3DBGRA.GetPixels( const X_,Y_,Z_:Integer ) :TAlphaColor;
begin
     Result := Map[ X_, Y_, Z_ ];
end;

procedure TTexture3DBGRA.SetPixels( const X_,Y_,Z_:Integer; const Pixel_:TAlphaColor );
begin
     Map[ X_, Y_, Z_ ] := Pixel_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTexture3DBGRA.Create;
begin
     inherited;

     _Map := TArray3D<TAlphaColor>.Create;

     PixelFormat := TPixelFormat.BGRA;
end;

destructor TTexture3DBGRA.Destroy;
begin
     _Map.Free;

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■