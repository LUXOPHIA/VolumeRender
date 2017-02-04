unit LUX.FMX.ScatterPlotFrame;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Objects,
  LUX, LUX.D2, LUX.FMX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TScaleLine

     TScaleLine = record
     private
     public
       Scale :Single;
       Thick :Single;
       Color :TAlphacolor;
       /////
       constructor Create( const Scale_,Thick_:Single; const Color_:TAlphacolor );
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TScatterPlotFrame

     TScatterPlotFrame = class(TFrame)
     private
     protected
       { private 宣言 }
       _Margin    :Single;
       _Area      :TRectF;
       _MinX      :Single;
       _MaxX      :Single;
       _MinY      :Single;
       _MaxY      :Single;
       _BackColor :TAlphaColor;
       _AreaColor :TAlphaColor;
       _Plots     :TArray<TSingle2D>;
       _PlotsN    :Integer;
       _PlotSize  :Single;
       _PlotColor :TAlphaColor;
       _Focus     :Integer;
       _Hover     :Integer;
       _ScaleX    :TArray<TScaleLine>;
       _ScaleY    :TArray<TScaleLine>;
       _ScaleN    :Integer;
       _FontColor :TAlphaColor;
       ///// アクセス
       procedure SetMargin( const Margin_:Single ); virtual;
       procedure SetMinX( const MinX_:Single ); virtual;
       procedure SetMaxX( const MaxX_:Single ); virtual;
       procedure SetMinY( const MinY_:Single ); virtual;
       procedure SetMaxY( const MaxY_:Single ); virtual;
       procedure SetBackColor( const BackColor_:TAlphaColor ); virtual;
       procedure SetAreaColor( const AreaColor_:TAlphaColor ); virtual;
       function GetPlot( const I_:Integer ) :TSingle2D; virtual;
       procedure SetPlot( const I_:Integer; const Plot_:TSingle2D ); virtual;
       procedure SetPlotsN( const PlotsN_:Integer ); virtual;
       procedure SetPlotSize( const PlotSize_:Single ); virtual;
       procedure SetPlotColor( const PlotColor_:TAlphaColor ); virtual;
       procedure SetFocus( const Focus_:Integer ); virtual;
       procedure SetHover( const Hover_:Integer ); virtual;
       function GetScaleX( const I_:Integer ) :TScaleLine; virtual;
       procedure SetScaleX( const I_:Integer; const ScaleX_:TScaleLine ); virtual;
       function GetScaleY( const I_:Integer ) :TScaleLine; virtual;
       procedure SetScaleY( const I_:Integer; const ScaleY_:TScaleLine ); virtual;
       procedure SetScaleN( const ScaleN_:Integer ); virtual;
       procedure SetFontColor( const FontColor_:TAlphaColor ); virtual;
       ///// メソッド
       procedure MouseDown( Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single ); override;
       procedure MouseMove( Shift_:TShiftState; X_,Y_:Single); override;
       procedure MouseUp( Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single ); override;
       procedure Paint; override;
       procedure Resize; override;
       function ScrToPos( const S_:TPointF ) :TSingle2D;
       function PosToScr( const P_:TSingle2D ) :TPointF;
       procedure DrawPlots;
       procedure DrawAxis;
       procedure DrawScaleX( const Interval_:Single );
       procedure DrawScaleY( const Interval_:Single );
       procedure DrawValuesX( const Interval_:Single; const Digits_:Integer );
       procedure DrawValuesY( const Interval_:Single; const Digits_:Integer );
       ///// プロパティ
       property Hover :Integer read _Hover write SetHover;
     public
       { public 宣言 }
       constructor Create( AOwner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Margin                     :Single      read   _Margin    write SetMargin   ;
       property Area                       :TRectF      read   _Area                        ;
       property MinX                       :Single      read   _MinX      write SetMinX     ;
       property MaxX                       :Single      read   _MaxX      write SetMaxX     ;
       property MinY                       :Single      read   _MinY      write SetMinY     ;
       property MaxY                       :Single      read   _MaxY      write SetMaxY     ;
       property BackColor                  :TAlphaColor read   _BackColor write SetBackColor;
       property AreaColor                  :TAlphaColor read   _AreaColor write SetAreaColor;
       property Plots[ const I_:Integer ]  :TSingle2D   read GetPlot      write SetPlot     ; default;
       property PlotsN                     :Integer     read   _PlotsN    write SetPlotsN   ;
       property PlotSize                   :Single      read   _PlotSize  write SetPlotSize ;
       property PlotColor                  :TAlphaColor read   _PlotColor write SetPlotColor;
       property Focus                      :Integer     read   _Focus     write SetFocus    ;
       property ScaleX[ const I_:Integer ] :TScaleLine  read GetScaleX    write SetScaleX   ;
       property ScaleY[ const I_:Integer ] :TScaleLine  read GetScaleY    write SetScaleY   ;
       property ScaleN                     :Integer     read   _ScaleN    write SetScaleN   ;
       property FontColor                  :TAlphaColor read   _FontColor write SetFontColor;
       ///// メソッド
       function FindNearPlot( const Scr_:TPointF ) :Integer; overload;
       function FindNearPlot( const Pos_:TSingle2D ) :Integer; overload;
     end;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TScaleLine

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TScaleLine.Create( const Scale_,Thick_:Single; const Color_:TAlphacolor );
begin
     Scale := Scale_;
     Thick := Thick_;
     Color := Color_;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TScatterPlotFrame

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TScatterPlotFrame.SetMargin( const Margin_:Single );
begin
     _Margin := Margin_;  Repaint;
end;

procedure TScatterPlotFrame.SetMinX( const MinX_:Single );
begin
     _MinX := MinX_;  Repaint;
end;

procedure TScatterPlotFrame.SetMaxX( const MaxX_:Single );
begin
     _MaxX := MaxX_;  Repaint;
end;

procedure TScatterPlotFrame.SetMinY( const MinY_:Single );
begin
     _MinY := MinY_;  Repaint;
end;

procedure TScatterPlotFrame.SetMaxY( const MaxY_:Single );
begin
     _MaxY := MaxY_;  Repaint;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.SetBackColor( const BackColor_:TAlphaColor );
begin
     _BackColor := BackColor_;  Repaint;
end;

procedure TScatterPlotFrame.SetAreaColor( const AreaColor_:TAlphaColor );
begin
     _AreaColor := AreaColor_;  Repaint;
end;

//------------------------------------------------------------------------------

function TScatterPlotFrame.GetPlot( const I_:Integer ) :TSingle2D;
begin
     Result := _Plots[ I_ ];
end;

procedure TScatterPlotFrame.SetPlot( const I_:Integer; const Plot_:TSingle2D );
begin
     _Plots[ I_ ] := Plot_;
end;

procedure TScatterPlotFrame.SetPlotsN( const PlotsN_:Integer );
begin
     _PlotsN := PlotsN_;

     SetLength( _Plots, _PlotsN );
end;

procedure TScatterPlotFrame.SetPlotSize( const PlotSize_:Single );
begin
     _PlotSize := PlotSize_;  Repaint;
end;

procedure TScatterPlotFrame.SetPlotColor( const PlotColor_:TAlphaColor );
begin
     _PlotColor := PlotColor_;  Repaint;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.SetFocus( const Focus_:Integer );
begin
     _Focus := Focus_;  Repaint;
end;

procedure TScatterPlotFrame.SetHover( const Hover_:Integer );
begin
     _Hover := Hover_;  Repaint;
end;

//------------------------------------------------------------------------------

function TScatterPlotFrame.GetScaleX( const I_:Integer ) :TScaleLine;
begin
     Result := _ScaleX[ I_ ];
end;

procedure TScatterPlotFrame.SetScaleX( const I_:Integer; const ScaleX_:TScaleLine );
begin
     _ScaleX[ I_ ] := ScaleX_;  Repaint;
end;

function TScatterPlotFrame.GetScaleY( const I_:Integer ) :TScaleLine;
begin
     Result := _ScaleY[ I_ ];
end;

procedure TScatterPlotFrame.SetScaleY( const I_:Integer; const ScaleY_:TScaleLine );
begin
     _ScaleY[ I_ ] := ScaleY_;  Repaint;
end;

procedure TScatterPlotFrame.SetScaleN( const ScaleN_:Integer );
begin
     _ScaleN := ScaleN_;

     SetLength( _ScaleX, _ScaleN );
     SetLength( _ScaleY, _ScaleN );

     Repaint;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.SetFontColor( const FontColor_:TAlphaColor );
begin
     _FontColor := FontColor_;  Repaint;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TScatterPlotFrame.MouseDown( Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single );
begin
     inherited;

     Focus := FindNearPlot( TPointF.Create( X_, Y_ ) );
end;

procedure TScatterPlotFrame.MouseMove( Shift_:TShiftState; X_,Y_:Single );
begin
     inherited;

     Hover := FindNearPlot( TPointF.Create( X_, Y_ ) );
end;

procedure TScatterPlotFrame.MouseUp( Button_:TMouseButton; Shift_:TShiftState; X_,Y_:Single );
begin
     inherited;

end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.Paint;
var
   I :Integer;
begin
     inherited;

     with Canvas do
     begin
          Stroke.Kind := TBrushKind.Solid;
          Fill  .Kind := TBrushKind.Solid;

          //////////

          Clear( _BackColor );

          //////////

          Fill.Color := _AreaColor;

          FillRect( _Area, 0, 0, [], 1 );

          //////////

          for I := _ScaleN-1 downto 0 do
          begin
               with _ScaleX[ I ] do
               begin
                    Stroke.Thickness := Thick;
                    Stroke.Color     := Color;

                    DrawScaleX( Scale );
               end;

               with _ScaleY[ I ] do
               begin
                    Stroke.Thickness := Thick;
                    Stroke.Color     := Color;

                    DrawScaleY( Scale );
               end;
          end;

          //////////

          with Stroke do
          begin
               Thickness := 2.0;
               Color     := TAlphaColors.White;
          end;

          DrawAxis;

          //////////

          Font.Size := 15;

          Fill.Color := _FontColor;

          DrawValuesX( _ScaleX[0].Scale, 1 );
          DrawValuesY( _ScaleY[0].Scale, 1 );

          //////////

          with Stroke do
          begin
               Thickness := 2;
               Color     := TAlphaColors.Lime;
          end;

          DrawPlots;
     end;
end;

procedure TScatterPlotFrame.Resize;
begin
     inherited;

     _Area := TRectF.Create( _Margin, _Margin, Width-_Margin, Height-_Margin );
end;

//------------------------------------------------------------------------------

function TScatterPlotFrame.ScrToPos( const S_:TPointF ) :TSingle2D;
begin
     Result.X := ( _MaxX - _MinX ) * ( S_.X - _Area.Left ) / _Area.Width  + _MinX;
     Result.Y := ( _MinY - _MaxY ) * ( S_.Y - _Area.Top  ) / _Area.Height + _MaxY;
end;

function TScatterPlotFrame.PosToScr( const P_:TSingle2D ) :TPointF;
begin
     Result.X := ( P_.X - _MinX ) / ( _MaxX - _MinX ) * _Area.Width  + _Area.Left;
     Result.Y := ( P_.Y - _MaxY ) / ( _MinY - _MaxY ) * _Area.Height + _Area.Top ;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.DrawPlots;
var
   I :Integer;
   P :TPointF;
begin
     with Canvas do
     begin
          for I := 0 to High( _Plots ) do
          begin
               P := PosToScr( _Plots[ I ] );

               if I = _Hover then
               begin
                    DrawCircle( P, 2 * _PlotSize );
               end;

               if I = _Focus then
               begin
                    Fill.Color := TAlphaColors.Red;

                    FillCircle( P, _PlotSize );
               end
               else
               begin
                    Fill.Color := _PlotColor;

                    FillCircle( P, _PlotSize );
               end;
          end;
     end;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.DrawAxis;
begin
     with Canvas do
     begin
          DrawLine( PosToScr( TSingle2D.Create( 0, _MinY ) ),
                    PosToScr( TSingle2D.Create( 0, _MaxY ) ), 1 );

          DrawLine( PosToScr( TSingle2D.Create( _MinX, 0 ) ),
                    PosToScr( TSingle2D.Create( _MaxX, 0 ) ), 1 );
     end;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.DrawScaleX( const Interval_ :Single );
var
   X0, X1, X :Integer;
   P0, P1 :TSingle2D;
begin
     X0 := Ceil( _MinX / Interval_ );  X1 := Floor( _MaxX / Interval_ );

     with Canvas do
     begin
          P0.Y := _MinY;  P1.Y := _MaxY;
          for X := X0 to X1 do
          begin
               P0.X := Interval_ * X;  P1.X := P0.X;

               DrawLine( PosToScr( P0 ), PosToScr( P1 ), 1 );
          end;
     end;
end;

procedure TScatterPlotFrame.DrawScaleY( const Interval_ :Single );
var
   Y0, Y1, Y :Integer;
   P0, P1 :TSingle2D;
begin
     Y0 := Ceil( _MinY / Interval_ );  Y1 := Floor( _MaxY / Interval_ );

     with Canvas do
     begin
          P0.X := _MinX;  P1.X := _MaxX;
          for Y := Y0 to Y1 do
          begin
               P0.Y := Interval_ * Y;  P1.Y := P0.Y;

               DrawLine( PosToScr( P0 ), PosToScr( P1 ), 1 );
          end;
     end;
end;

//------------------------------------------------------------------------------

procedure TScatterPlotFrame.DrawValuesX( const Interval_ :Single; const Digits_:Integer );
var
   X0, X1, X :Integer;
   P :TSingle2D;
   S :TPointF;
   T :String;
begin
     X0 := Ceil( _MinX / Interval_ );  X1 := Floor( _MaxX / Interval_ );

     with Canvas do
     begin
          P.Y := _MinY;
          for X := X0 to X1 do
          begin
               P.X := Interval_ * X;

               T := FloatToStrF( P.X, TFloatFormat.ffFixed, 7, Digits_ );

               S := PosToScr( P );

               with S do Y := Y - 0.37*Font.Size + Font.Size/2;

               DrawText( T, S, TTextAlign.Center, TTextAlign.Leading );
          end;
     end;
end;

procedure TScatterPlotFrame.DrawValuesY( const Interval_ :Single; const Digits_:Integer );
var
   Y0, Y1, Y :Integer;
   P :TSingle2D;
   S :TPointF;
   T :String;
begin
     Y0 := Ceil( _MinY / Interval_ );  Y1 := Floor( _MaxY / Interval_ );

     with Canvas do
     begin
          P.X := _MinX;
          for Y := Y0 to Y1 do
          begin
               P.Y := Interval_ * Y;

               T := FloatToStrF( P.Y, TFloatFormat.ffFixed, 7, Digits_ );

               S := PosToScr( P );

               with S do X := X - Font.Size/2;

               DrawText( T, S, TTextAlign.Trailing, TTextAlign.Center );
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TScatterPlotFrame.Create( AOwner_:TComponent );
begin
     inherited;

     _Margin    := 50;

     _Area      := TRectF.Create( _Margin, _Margin, Width-_Margin, Height-_Margin );

     _MinX      := -10;
     _MaxX      := +10;
     _MinY      := -10;
     _MaxY      := +10;

     _BackColor := TAlphaColors.Dimgray;
     _AreaColor := TAlphaColors.Black;

     _Plots     := [];
     _PlotsN    := 0;
     _PlotSize  := 3;
     _PlotColor := TAlphaColors.Yellow;

     _Focus     := -1;
     _Hover     := -1;

      ScaleN    := 3;

      ScaleX[0] := TScaleLine.Create( 1.0, 1.00, $FFC0C0C0 );
      ScaleX[1] := TScaleLine.Create( 0.5, 0.75, $FF808080 );
      ScaleX[2] := TScaleLine.Create( 0.1, 0.50, $FF404040 );

      ScaleY[0] := TScaleLine.Create( 1.0, 1.00, $FFC0C0C0 );
      ScaleY[1] := TScaleLine.Create( 0.5, 0.75, $FF808080 );
      ScaleY[2] := TScaleLine.Create( 0.1, 0.50, $FF404040 );

     _FontColor := TAlphaColors.White;
end;

destructor TScatterPlotFrame.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TScatterPlotFrame.FindNearPlot( const Scr_:TPointF ) :Integer;
var
   MinD, D :Single;
   I :Integer;
begin
     Result := -1;  MinD := 4 * _PlotSize;

     for I := 0 to PlotsN-1 do
     begin
          D := Scr_.Distance( PosToScr( Plots[ I ] ) );

          if D < MinD then
          begin
               Result := I;  MinD := D;
          end;
     end;
end;

function TScatterPlotFrame.FindNearPlot( const Pos_:TSingle2D ) :Integer;
var
   MinD, D :Single;
   I :Integer;
begin
     Result := -1;  MinD := 0.1;

     for I := 0 to PlotsN-1 do
     begin
          D := Pos_.DistanTo( Plots[ I ] );

          if D < MinD then
          begin
               Result := I;  MinD := D;
          end;
     end;
end;

end. //######################################################################### ■
