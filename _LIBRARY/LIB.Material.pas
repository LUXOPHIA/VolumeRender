unit LIB.Material;

interface //#################################################################### ■

uses System.Classes, System.UITypes, System.Math.Vectors,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX, LUX.FMX.Material, LUX.FMX.Types3D;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterial

     TMyMaterial = class( TLuxMaterial )
     private
     protected
       _MatrixLS  :TShaderVarMatrix3D;
       _MatrixLG  :TShaderVarMatrix3D;
       _MatrixGL  :TShaderVarMatrix3D;
       _Light     :TShaderVarLight;
       _EyePos    :TShaderVarVector3D;
       _Opacity   :TShaderVarSingle;
       _Size      :TShaderVarPoint3D;
       _Texture3D :TShaderVarTexture3D<TTexture3DRGBA32F>;
       ///// メソッド
       procedure DoApply( const Context_:TContext3D ); override;
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Size      :TShaderVarPoint3D                      read _Size     ;
       property Texture3D :TShaderVarTexture3D<TTexture3DRGBA32F> read _Texture3D;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

     TMyMaterialSource = class( TLuxMaterialSource<TMyMaterial> )
     private
     protected
       ///// アクセス
       function GetSize :TPoint3D;
       procedure SetSize( const Size_:TPoint3D );
       function GetTexture3D :TTexture3DRGBA32F;
     public
       ///// プロパティ
       property Size      :TPoint3D          read GetSize      write SetSize;
       property Texture3D :TTexture3DRGBA32F read GetTexture3D              ;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TVolumeCube

     TVolumeCube = class( TControl3D )
     private
       ///// メソッド
       procedure MakeModel;
     protected
       _Geometry :TMeshData;
       _Material :TMyMaterialSource;
       ///// アクセス
       procedure SetWidth( const Value_:Single ); override;
       procedure SetHeight( const Value_:Single ); override;
       procedure SetDepth( const Value_:Single ); override;
       function GetTexture3D :TTexture3DRGBA32F;
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Material :TMyMaterialSource read _Material;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterial

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMyMaterial.DoApply( const Context_:TContext3D );
begin
     inherited;

     with Context_ do
     begin
          SetShaders( _ShaderV.Shader, _ShaderP.Shader );

          _MatrixLS.Value := CurrentModelViewProjectionMatrix;
          _MatrixLG.Value := CurrentMatrix;
          _MatrixGL.Value := CurrentMatrix.Inverse;
          _Light   .Value := Lights[ 0 ];
          _EyePos  .Value := CurrentCameraInvMatrix.M[ 3 ];
          _Opacity .Value := CurrentOpacity;
     end;

     _ShaderV.SendVars( Context_ );
     _ShaderP.SendVars( Context_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TMyMaterial.Create;
begin
     inherited;

     _MatrixLS  := TShaderVarMatrix3D                    .Create( '_MatrixLS'  );
     _MatrixLG  := TShaderVarMatrix3D                    .Create( '_MatrixLG'  );
     _MatrixGL  := TShaderVarMatrix3D                    .Create( '_MatrixGL'  );
     _Light     := TShaderVarLight                       .Create( '_Light'     );
     _EyePos    := TShaderVarVector3D                    .Create( '_EyePos'    );
     _Opacity   := TShaderVarSingle                      .Create( '_Opacity'   );
     _Size      := TShaderVarPoint3D                     .Create( '_Size'      );
     _Texture3D := TShaderVarTexture3D<TTexture3DRGBA32F>.Create( '_Texture3D' );

     _Size.Value := TPoint3D.Create( 1, 1, 1 );

     _ShaderV.Vars := [ _MatrixLS ];

     _ShaderP.Vars := [ _MatrixLG ,
                        _MatrixGL ,
                        _Light    ,
                        _EyePos   ,
                        _Opacity  ,
                        _Size     ,
                        _Texture3D ];
end;

destructor TMyMaterial.Destroy;
begin
     _MatrixLS .Free;
     _MatrixLG .Free;
     _MatrixGL .Free;
     _Light    .Free;
     _EyePos   .Free;
     _Opacity  .Free;
     _Size     .Free;
     _Texture3D.Free;

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TMyMaterialSource.GetSize :TPoint3D;
begin
     Result := _Material.Size.Value;
end;

procedure TMyMaterialSource.SetSize( const Size_:TPoint3D );
begin
     _Material.Size.Value := Size_;
end;

function TMyMaterialSource.GetTexture3D :TTexture3DRGBA32F;
begin
     Result := _Material.Texture3D.Value;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TVolumeCube

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

procedure TVolumeCube.MakeModel;
begin
     _Material.Size := TPoint3D.Create( Width, Height, Depth );

     with _Geometry do
     begin
          with VertexBuffer do
          begin
               Length := 8{Poin};

               Vertices[ 0 ] := TPoint3D.Create(     0,      0,     0 );
               Vertices[ 1 ] := TPoint3D.Create( Width,      0,     0 );
               Vertices[ 2 ] := TPoint3D.Create(     0, Height,     0 );
               Vertices[ 3 ] := TPoint3D.Create( Width, Height,     0 );
               Vertices[ 4 ] := TPoint3D.Create(     0,      0, Depth );
               Vertices[ 5 ] := TPoint3D.Create( Width,      0, Depth );
               Vertices[ 6 ] := TPoint3D.Create(     0, Height, Depth );
               Vertices[ 7 ] := TPoint3D.Create( Width, Height, Depth );
          end;

          with IndexBuffer do
          begin
               Length := 3{Poin} * 2{Face} * 6{Quad};

               {         4           5
                        100---------101
                      ／ |        ／ |
                  0 ／   |    1 ／   |
                 000---------001     |
                  |      |    |      |
                  |      |    |      |
                  |     110---|-----111
                  |   ／ 6    |   ／ 7
                  | ／        | ／
                 010---------011
                  2           3          }

               Indices[ 00 ] := 0;  Indices[ 01 ] := 2;  Indices[ 02 ] := 4;
               Indices[ 03 ] := 6;  Indices[ 04 ] := 4;  Indices[ 05 ] := 2;

               Indices[ 06 ] := 1;  Indices[ 07 ] := 5;  Indices[ 08 ] := 3;
               Indices[ 09 ] := 7;  Indices[ 10 ] := 3;  Indices[ 11 ] := 5;

               Indices[ 12 ] := 0;  Indices[ 13 ] := 4;  Indices[ 14 ] := 1;
               Indices[ 15 ] := 5;  Indices[ 16 ] := 1;  Indices[ 17 ] := 4;

               Indices[ 18 ] := 2;  Indices[ 19 ] := 3;  Indices[ 20 ] := 6;
               Indices[ 21 ] := 7;  Indices[ 22 ] := 6;  Indices[ 23 ] := 3;

               Indices[ 24 ] := 0;  Indices[ 25 ] := 1;  Indices[ 26 ] := 2;
               Indices[ 27 ] := 3;  Indices[ 28 ] := 2;  Indices[ 29 ] := 1;

               Indices[ 30 ] := 4;  Indices[ 31 ] := 6;  Indices[ 32 ] := 5;
               Indices[ 33 ] := 7;  Indices[ 34 ] := 5;  Indices[ 35 ] := 6;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TVolumeCube.SetWidth( const Value_:Single );
begin
     inherited;

     MakeModel;
end;

procedure TVolumeCube.SetHeight( const Value_:Single );
begin
     inherited;

     MakeModel;
end;

procedure TVolumeCube.SetDepth( const Value_:Single );
begin
     inherited;

     MakeModel;
end;

function TVolumeCube.GetTexture3D :TTexture3DRGBA32F;
begin
     Result := _Material.Texture3D;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TVolumeCube.Render;
begin
     Context.SetMatrix( TMatrix3D.CreateTranslation( TPoint3D.Create( -Width/2, -Height/2, -Depth/2 ) ) * AbsoluteMatrix );

     _Geometry.Render( Context, TMaterialSource.ValidMaterial( _Material ), AbsoluteOpacity );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TVolumeCube.Create( Owner_:TComponent );
begin
     inherited;

     _Geometry := TMeshData.Create;
     _Material := TMyMaterialSource.Create( Self );

     HitTest := False;

     MakeModel;
end;

destructor TVolumeCube.Destroy;
begin
     _Geometry.Free;
     _Material.Free;

     inherited;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //######################################################## 初期化

finalization //########################################################## 最終化

end. //######################################################################### ■
