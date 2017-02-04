unit LUX.FMX.Types3D;

interface //#################################################################### ■

uses System.Messaging,
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
       _Map    :TArray3D;
       _Depth  :Integer;
       ///// アクセス
       procedure SetDepth( const Depth_:Integer );
       ///// メソッド
       procedure ContextLostHandler( const Sender:TObject; const Msg:TMessage );
       procedure ContextResetHandler( const Sender:TObject; const Msg:TMessage );
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Map   :TArray3D read _Map                 ;
       property Depth :Integer  read _Depth write SetDepth;
       ///// メソッド
       procedure SetSize( const Width_,Height_,Depth_:Integer );
       function IsEmpty :Boolean;
       procedure UpdateTexture;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3DBGRA

     TTexture3DBGRA = class( TTexture3D )
     private
     protected
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ

     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.UITypes, FMX.Types;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TTexture3D.SetDepth( const Depth_:Integer );
begin
     Finalize;

     _Depth := Depth_;
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
     Result := ( Width * Height * _Depth = 0 );
end;

procedure TTexture3D.SetSize( const Width_,Height_,Depth_:Integer );
begin
     inherited SetSize( Width_, Height_ );

     _Depth := Depth_;
end;

procedure TTexture3D.UpdateTexture;
begin
     if Assigned( _Map ) then TContextManager.DefaultContextClass.UpdateTexture( Self, _Map.Lines[ 0, 0 ], _Map.StepY );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTexture3DBGRA

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

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