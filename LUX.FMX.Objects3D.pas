unit LUX.FMX.Objects3D;

interface //#################################################################### ■

uses System.Types, System.Classes, System.Math.Vectors,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTwistRod

     TTwistRod = class( TControl3D )
     private
       ///// メソッド
       function XYtoI( const X_,Y_:Integer ) :Integer; inline;
       procedure MakeModel;
     protected
       _Geometry :TMeshData;
       _Material :TMaterialSource;
       _Radius   :Single;
       _DivH     :Integer;
       _DivR     :Integer;
       _AngleT   :Single;
       _AngleB   :Single;
       ///// アクセス
       procedure SetHeight( const Radius_:Single ); override;
       procedure SetRadius( const Radius_:Single ); virtual;
       procedure SetDivH( const DivH_:Integer ); virtual;
       procedure SetDivR( const DivR_:Integer ); virtual;
       procedure SetAngleT( const AngleT_:Single ); virtual;
       procedure SetAngleB( const AngleB_:Single ); virtual;
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Material :TMaterialSource read _Material write   _Material;
       property Radius   :Single          read _Radius   write SetRadius  ;
       property DivH     :Integer         read _DivH     write SetDivH    ;
       property DivR     :Integer         read _DivR     write SetDivR    ;
       property AngleT   :Single          read _AngleT   write SetAngleT  ;
       property AngleB   :Single          read _AngleB   write SetAngleB  ;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts, System.Math;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTwistRod

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

function TTwistRod.XYtoI( const X_,Y_:Integer ) :Integer;
begin
     Result := ( _DivR + 1 ) * Y_ + X_;
end;

procedure TTwistRod.MakeModel;
var
   X ,Y, I :Integer;
   T :TPointF;
   N, P :TPoint3D;
   S, B, R, A :Single;
begin
     with _Geometry do
     begin
          with VertexBuffer do
          begin
               Length := ( _DivR + 1 ) * ( _DivH + 1 );

               for Y := 0 to _DivH do
               begin
                    T.Y := Y / _DivH;

                    N.Y := 0;
                    P.Y := Height * ( T.Y - 0.5 );

                    S := ( 1 - Cos( Pi * T.Y ) ) / 2;

                    B := ( _AngleB - _AngleT ) * S + _AngleT;

                    R := _Radius;

                    for X := 0 to _DivR do
                    begin
                         T.X := X / _DivR;

                         A := B + Pi2 * T.X;

                         N.X := Cos( A );
                         N.Z := Sin( A );

                         P.X := R * N.X;
                         P.Z := R * N.Z;

                         I := XYtoI( X, Y );

                         Vertices [ I ] := P;
                         Normals  [ I ] := N;
                         TexCoord0[ I ] := T;
                    end;
               end;
          end;

          with IndexBuffer do
          begin
               Length := 3{Poin} * 2{Face} * _DivR * _DivH;

               I := 0;
               for Y := 0 to _DivH-1 do
               begin
                    for X := 0 to _DivR-1 do
                    begin
                         //    X0      X1
                         //  Y0┼───┼
                         //    │＼    │
                         //    │  ＼  │
                         //    │    ＼│
                         //  Y1┼───┼

                         Indices[ I ] := XYtoI( X  , Y   );  Inc( I );
                         Indices[ I ] := XYtoI( X+1, Y   );  Inc( I );
                         Indices[ I ] := XYtoI( X+1, Y+1 );  Inc( I );

                         Indices[ I ] := XYtoI( X+1, Y+1 );  Inc( I );
                         Indices[ I ] := XYtoI( X  , Y+1 );  Inc( I );
                         Indices[ I ] := XYtoI( X  , Y   );  Inc( I );
                    end;
               end;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TTwistRod.SetHeight( const Radius_:Single );
begin
     inherited;

     MakeModel;
end;

procedure TTwistRod.SetRadius( const Radius_:Single );
begin
     _Radius := Radius_;  MakeModel;
end;

procedure TTwistRod.SetDivH( const DivH_:Integer );
begin
     _DivH := DivH_;  MakeModel;
end;
procedure TTwistRod.SetDivR( const DivR_:Integer );
begin
     _DivR := DivR_;  MakeModel;
end;

procedure TTwistRod.SetAngleT( const AngleT_:Single );
begin
     _AngleT := AngleT_;  MakeModel;
end;

procedure TTwistRod.SetAngleB( const AngleB_:Single );
begin
     _AngleB := AngleB_;  MakeModel;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TTwistRod.Render;
begin
     Context.SetMatrix( AbsoluteMatrix);

     _Geometry.Render( Context, TMaterialSource.ValidMaterial(_Material), AbsoluteOpacity );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTwistRod.Create( Owner_:TComponent );
begin
     inherited;

     _Geometry := TMeshData.Create;

     FHeight := 3;
     _Radius := 1;
     _DivH   := 10;
     _DivR   := 36;
     _AngleT := 0;
     _AngleB := 0;

     MakeModel;
end;

destructor TTwistRod.Destroy;
begin
     _Geometry.Free;

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
