unit LUX.FMX.TTrueViewport3D;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls3D,
  LUX.FMX;

type
  TTrueViewport3DFrame = class(TFrame)
  private
    { private 宣言 }
    _Viewport3D :TTrueViewport3D;
    ///// アクセス
    function GetColor :TAlphaColor;
    procedure SetColor( const Color_:TAlphaColor );
    function GetCamera :TCamera;
    procedure SetCamera( const Camera_:TCamera );
  public
    { public 宣言 }
    constructor Create( Owner_:TComponent ); override;
    destructor Destroy; override;
    ///// プロパティ
    property Color  :TAlphaColor read GetColor  write SetColor;
    property Camera :TCamera     read GetCamera write SetCamera;
    ///// メソッド
    procedure RebuildRenderingList;
  end;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// アクセス

function TTrueViewport3DFrame.GetColor :TAlphaColor;
begin
     Result := _Viewport3D.Color;
end;

procedure TTrueViewport3DFrame.SetColor( const Color_:TAlphaColor );
begin
     _Viewport3D.Color := Color_;
end;

function TTrueViewport3DFrame.GetCamera :TCamera;
begin
     Result := _Viewport3D.Camera;
end;

procedure TTrueViewport3DFrame.SetCamera( const Camera_:TCamera );
begin
     _Viewport3D.Camera := Camera_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTrueViewport3DFrame.Create( Owner_:TComponent );
begin
     inherited;

     AutoCapture := True;

     _Viewport3D := TTrueViewport3D.Create( Owner_ );

     with _Viewport3D do
     begin
          HitTest := False;
          Parent  := Self;
          Align   := TAlignLayout.Client;
     end;
end;

destructor TTrueViewport3DFrame.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TTrueViewport3DFrame.RebuildRenderingList;
begin
     _Viewport3D.RebuildRenderingList;
end;

end. //######################################################################### ■
