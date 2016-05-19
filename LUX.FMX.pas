unit LUX.FMX;

interface //#################################################################### ■

uses System.Classes, System.UITypes, System.Math.Vectors,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTensors

     TTensors = class( TControl3D )
     private
     protected
       _GeometryX :TMeshData;
       _GeometryY :TMeshData;
       _GeometryZ :TMeshData;
       _MaterialX :TColorMaterialSource;
       _MaterialY :TColorMaterialSource;
       _MaterialZ :TColorMaterialSource;
       _MeshData  :TMeshData;
       _AxisSize  :Single;
       ///// アクセス
       procedure SetMeshData( const MeshData_:TMeshData );
       procedure SetAxisSize( const AxisSize_:Single );
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property MeshData :TMeshData read _MeshData write SetMeshData;
       property AxisSize :Single    read _AxisSize write SetAxisSize;
       ///// メソッド
       procedure MakeModel;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTensors

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TTensors.SetMeshData( const MeshData_:TMeshData );
begin
     _MeshData := MeshData_;  MakeModel;
end;

procedure TTensors.SetAxisSize( const AxisSize_:Single );
begin
     _AxisSize := AxisSize_;  MakeModel;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TTensors.Render;
begin
     with Context do
     begin
          SetMatrix( AbsoluteMatrix );

          DrawLines( _GeometryX.VertexBuffer, _GeometryX.IndexBuffer, _MaterialX.Material, AbsoluteOpacity );
          DrawLines( _GeometryY.VertexBuffer, _GeometryY.IndexBuffer, _MaterialY.Material, AbsoluteOpacity );
          DrawLines( _GeometryZ.VertexBuffer, _GeometryZ.IndexBuffer, _MaterialZ.Material, AbsoluteOpacity );
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTensors.Create( Owner_:TComponent );
begin
     inherited;

     HitTest := False;

     _GeometryX := TMeshData.Create;
     _GeometryY := TMeshData.Create;
     _GeometryZ := TMeshData.Create;

     _MaterialX := TColorMaterialSource.Create( Self );
     _MaterialY := TColorMaterialSource.Create( Self );
     _MaterialZ := TColorMaterialSource.Create( Self );

     _MaterialX.Color := TAlphaColors.Red;
     _MaterialY.Color := TAlphaColors.Lime;
     _MaterialZ.Color := TAlphaColors.Blue;

     _AxisSize := 0.05;
end;

destructor TTensors.Destroy;
begin
     _GeometryX.Free;
     _GeometryY.Free;
     _GeometryZ.Free;

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TTensors.MakeModel;
var
   N, I, J :Integer;
   P, EX, EY, EZ :TPoint3D;
begin
     with _MeshData.VertexBuffer do
     begin
          N := Length * 2{Poin};

          _GeometryX.VertexBuffer.Length := N;
          _GeometryY.VertexBuffer.Length := N;
          _GeometryZ.VertexBuffer.Length := N;

          _GeometryX.IndexBuffer .Length := N;
          _GeometryY.IndexBuffer .Length := N;
          _GeometryZ.IndexBuffer .Length := N;

          J := 0;
          for I := 0 to Length-1 do
          begin
               P  := Vertices [ I ];
               EX := Tangents [ I ];
               EY := BiNormals[ I ];
               EZ := Normals  [ I ];

               _GeometryX.VertexBuffer.Vertices[ J ] := P;
               _GeometryY.VertexBuffer.Vertices[ J ] := P;
               _GeometryZ.VertexBuffer.Vertices[ J ] := P;

               _GeometryX.IndexBuffer .Indices [ J ] := J;
               _GeometryY.IndexBuffer .Indices [ J ] := J;
               _GeometryZ.IndexBuffer .Indices [ J ] := J;

               Inc( J );

               _GeometryX.VertexBuffer.Vertices[ J ] := P + _AxisSize * EX;
               _GeometryY.VertexBuffer.Vertices[ J ] := P + _AxisSize * EY;
               _GeometryZ.VertexBuffer.Vertices[ J ] := P + _AxisSize * EZ;

               _GeometryX.IndexBuffer .Indices [ J ] := J;
               _GeometryY.IndexBuffer .Indices [ J ] := J;
               _GeometryZ.IndexBuffer .Indices [ J ] := J;

               Inc( J );
          end;
     end;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
