unit LUX.Lattice.T1.D1;

interface //#################################################################### ■

uses LUX.Lattice.T1, LUX.Curve.T1.D1;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TSingleIrreMap1D

     TSingleIrreMap1D = class( TIrreMap1D<Single> )
     private
     protected
       ///// メソッド
       function Interp( const G0_,G1_,G2_,G3_:Single; const Id_:Single ) :Single; overload; override;
       function InterpPos( const G0_,G1_,G2_,G3_:TPosval1D<Single>; const Pos_:Single ) :Single; overload; override;
     public
       ///// メソッド
       function Interp( const I_:Single ) :Single; override;                    {ToDo: ジェネリックスのエラーバグ対策}
       function InterpPos( const Pos_:Single ) :Single; override;               {ToDo: ジェネリックスのエラーバグ対策}
       procedure MakeEdgeExtend;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TSingleIrreMap1D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

function TSingleIrreMap1D.Interp( const G0_,G1_,G2_,G3_:Single; const Id_:Single ) :Single;
begin
     Result := CatmullRom( G0_, G1_, G2_, G3_, Id_ );
end;

function TSingleIrreMap1D.InterpPos( const G0_,G1_,G2_,G3_:TPosval1D<Single>; const Pos_:Single ) :Single;
begin
     Result := CatmullRom( G0_.Val, G1_.Val, G2_.Val, G3_.Val,
                           G0_.Pos, G1_.Pos, G2_.Pos, G3_.Pos, Pos_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TSingleIrreMap1D.Interp( const I_:Single ) :Single;
begin
     Result := inherited;
end;

function TSingleIrreMap1D.InterpPos( const Pos_:Single ) :Single;
begin
     Result := inherited;
end;

procedure TSingleIrreMap1D.MakeEdgeExtend;
var
   G0, G1, G2 :TPosval1D<Single>;
begin
     G1 := Item[ 0 ];
     G2 := Item[ 1 ];
     with G0 do
     begin
          Pos := 2 * G1.Pos - G2.Pos;
          Val := 2 * G1.Val - G2.Val;
     end;
     Grid[ -1 ] := G0;

     G0 := Item[ BricN-1 ];
     G1 := Item[ BricN   ];
     with G2 do
     begin
          Pos := 2 * G1.Pos - G0.Pos;
          Val := 2 * G1.Val - G0.Val;
     end;
     Grid[ BricN+1 ] := G2;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
