unit LUX.FMX.Material;

interface //#################################################################### ■

uses System.Classes, System.UITypes, System.Generics.Collections,
     System.Types, System.Math.Vectors,
     FMX.Types3D, FMX.MaterialSources,
     Winapi.D3DCommon, Winapi.D3D11Shader, Winapi.D3DCompiler,
     LUX;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TShaderVar                   = class;
       TShaderVar<_TValue_>       = class;
         TShaderVarPrim<_TValue_> = class;
           TShaderVarSingle       = class;
           TShaderVarPointF       = class;
           TShaderVarPoint3D      = class;
           TShaderVarVector3D     = class;
           TShaderVarColor        = class;
           TShaderVarColorF       = class;
           TShaderVarMatrix3D     = class;
           TShaderVarTexture      = class;
         TShaderVarLight          = class;
     TShaderSource                = class;
       TShaderSourceV             = class;
       TShaderSourceP             = class;

     TLuxMaterial                 = class;

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
       property Size :Integer read GetSize            ;
       ///// メソッド
       function GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables; virtual; abstract;
       procedure SendVar( const Context_:TContext3D ); virtual; abstract;
       function GetSource( var C_:Integer; var T_:Integer ) :String; virtual; abstract;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVar<_TValue_>

     TShaderVar<_TValue_> = class( TShaderVar )
     private
     protected
       _Value :_TValue_;
       ///// アクセス
       procedure SetValue( const Value_:_TValue_ ); virtual;
     public
       ///// プロパティ
       property Value :_TValue_ read _Value write SetValue;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPrim

     TShaderVarPrim<_TValue_> = class( TShaderVar<_TValue_> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; virtual; abstract;
     public
       ///// プロパティ
       property Kind :TContextShaderVariableKind read GetKind;
       ///// メソッド
       function GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarSingle

     TShaderVarSingle = class( TShaderVarPrim<Single> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPointF

     TShaderVarPointF = class( TShaderVarPrim<TPointF> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPoint3D

     TShaderVarPoint3D = class( TShaderVarPrim<TPoint3D> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarVector3D

     TShaderVarVector3D = class( TShaderVarPrim<TVector3D> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarColor

     TShaderVarColor = class( TShaderVarPrim<TAlphaColor> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarColorF

     TShaderVarColorF = class( TShaderVarPrim<TAlphaColorF> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarMatrix3D

     TShaderVarMatrix3D = class( TShaderVarPrim<TMatrix3D> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       function GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables; override;
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarTexture

     TShaderVarTexture = class( TShaderVarPrim<TTexture> )
     private
     protected
       ///// アクセス
       function GetKind :TContextShaderVariableKind; override;
       function GetSize :Integer; override;
     public
       ///// メソッド
       procedure SendVar( const Context_:TContext3D ); override;
       function GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables; override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarLight

     TShaderVarLight = class( TShaderVar<TLightDescription> )
     private
       _Opt :TShaderVarPoint3D;
       _Pos :TShaderVarPoint3D;
       _Dir :TShaderVarPoint3D;
       _Col :TShaderVarColor;
     protected
       ///// アクセス
       function GetSize :Integer; override;
       procedure SetValue( const Value_:TLightDescription ); override;
     public
       constructor Create( const Name_:String );
       destructor Destroy; override;
       ///// メソッド
       function GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables; override;
       procedure SendVar( const Context_:TContext3D ); override;
       function GetSource( var C_:Integer; var T_:Integer ) :String; override;
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
       function GetVars( const A_:TContextShaderArch ) :TContextShaderVariables;
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
       ///// メソッド
       procedure DoInitialize; override;
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

uses System.SysUtils, System.IOUtils, System.Math, System.AnsiStrings;

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

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVar<_TValue_>

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TShaderVar<_TValue_>.SetValue( const Value_:_TValue_ );
begin
     _Value := Value_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPrim<_TValue_>

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarPrim<_TValue_>.GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( Name, Kind, I_, U_ * Size ) ];

     Inc( I_, Size * U_ );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarSingle

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarSingle.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float;
end;

function TShaderVarSingle.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarSingle.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value, 0, 0, 0 ) ] );
end;

function TShaderVarSingle.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPointF

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarPointF.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float2;
end;

function TShaderVarPointF.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarPointF.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value.X, _Value.Y, 0, 0 ) ] );
end;

function TShaderVarPointF.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float2 ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarPoint3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarPoint3D.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Float3;
end;

function TShaderVarPoint3D.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarPoint3D.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, [ TVector3D.Create( _Value.X, _Value.Y, _Value.Z, 0 ) ] );
end;

function TShaderVarPoint3D.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float3 ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarVector3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarVector3D.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Vector;
end;

function TShaderVarVector3D.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarVector3D.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarVector3D.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float4 ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
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

function TShaderVarColor.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float4 ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarColorF

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarColorF.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Vector;
end;

function TShaderVarColorF.GetSize :Integer;
begin
     Result := 1;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TShaderVarColorF.SendVar( const Context_:TContext3D );
begin
     with _Value do Context_.SetShaderVariable( _Name, TVector3D.Create( R, G, B, A ) );
end;

function TShaderVarColorF.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float4 ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarMatrix3D

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarMatrix3D.GetKind :TContextShaderVariableKind;
begin
     Result := TContextShaderVariableKind.Matrix;
end;

function TShaderVarMatrix3D.GetSize :Integer;
begin
     Result := 4;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarMatrix3D.GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( Name + '_', Kind, I_, U_ * Size ) ];

     Inc( I_, Size * U_ );
end;

procedure TShaderVarMatrix3D.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name + '_', _Value );
end;

function TShaderVarMatrix3D.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'float4x4 ' + _Name + '_ : register( c' + c_.ToString + ' );  static float4x4 ' + _Name + ' = transpose( ' + _Name + '_ );' + CRLF;

     Inc( c_, Size );
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

function TShaderVarTexture.GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := [ TContextShaderVariable.Create( Name, Kind, T_, U_ * Size ) ];

     Inc( T_, 1 );
end;

procedure TShaderVarTexture.SendVar( const Context_:TContext3D );
begin
     Context_.SetShaderVariable( _Name, _Value );
end;

function TShaderVarTexture.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'Texture2D<float4> ' + _Name + ' : register( t' + t_.ToString + ' );' + CRLF;

     Inc( t_, 1 );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TShaderVarLight

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TShaderVarLight.GetSize :Integer;
begin
     Result := _Opt.Size
             + _Pos.Size
             + _Dir.Size
             + _Col.Size;
end;

procedure TShaderVarLight.SetValue( const Value_:TLightDescription );
begin
     inherited;

     with _Value do
     begin
          _Opt.Value := TPoint3D.Create( Integer( LightType ) + 1     ,
                                         Cos( DegToRad( SpotCutoff ) ),
                                         SpotExponent                  );
          _Pos.Value := Position;
          _Dir.Value := Direction;
          _Col.Value := Color;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TShaderVarLight.Create( const Name_:String );
begin
     inherited;

     _Opt := TShaderVarPoint3D.Create( _Name + '.Opt' );
     _Pos := TShaderVarPoint3D.Create( _Name + '.Pos' );
     _Dir := TShaderVarPoint3D.Create( _Name + '.Dir' );
     _Col := TShaderVarColor  .Create( _Name + '.Col' );
end;

destructor TShaderVarLight.Destroy;
begin
     _Opt.Free;
     _Pos.Free;
     _Dir.Free;
     _Col.Free;
end;

/////////////////////////////////////////////////////////////////////// メソッド

function TShaderVarLight.GetVars( var I_,T_:Integer; const U_:Byte ) :TContextShaderVariables;
begin
     Result := _Opt.GetVars( I_, T_, U_ )
             + _Pos.GetVars( I_, T_, U_ )
             + _Dir.GetVars( I_, T_, U_ )
             + _Col.GetVars( I_, T_, U_ );
end;

procedure TShaderVarLight.SendVar( const Context_:TContext3D );
begin
     _Opt.SendVar( Context_ );
     _Pos.SendVar( Context_ );
     _Dir.SendVar( Context_ );
     _Col.SendVar( Context_ );
end;

function TShaderVarLight.GetSource( var C_:Integer; var T_:Integer ) :String;
begin
     Result := 'struct TLight'                                               + CRLF
             + '{'                                                           + CRLF
             + '    float3 Opt;'                                             + CRLF
             + '    float3 Pos;'                                             + CRLF
             + '    float3 Dir;'                                             + CRLF
             + '    float4 Col;'                                             + CRLF
             + '};'                                                          + CRLF
             + 'TLight ' + _Name + ' : register( c' + c_.ToString + ' );' + CRLF;

     Inc( c_, Size );
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

function TShaderSource.GetVars( const A_:TContextShaderArch ) :TContextShaderVariables;
var
   V :TShaderVar;
   C, T :Integer;
begin
     Result := [];  C := 0;  T := 0;

     for V in _Vars do Result := Result + V.GetVars( C, T, VARUNIT[ A_ ] );
end;

procedure TShaderSource.Compile;
var
   S, N, T, Cs :AnsiString;
   CSSs :array of TContextShaderSource;
   A :TContextShaderArch;
   H :HResult;
   B, E :ID3DBlob;
   Bs :TArray<Byte>;
begin
     TShaderManager.UnregisterShader( _Shader );

     _Errors.Clear;

     S := AnsiString( GetSources + _Source.Text );
     N := AnsiString( _Name );

     CSSs := [];

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
               SetLength( Cs, E.GetBufferSize );

               System.AnsiStrings.StrCopy( PAnsiChar( Cs ), E.GetBufferPointer );

               _Errors.Add( T, Cs );

               Exit;
          end;

          SetLength( Bs, B.GetBufferSize );
          Move( B.GetBufferPointer^, Bs[0], B.GetBufferSize );

          CSSs := CSSs + [ TContextShaderSource.Create( A, Bs, GetVars( A ) ) ];
     end;

     _Shader := TShaderManager.RegisterShaderFromData( _Name, GetKind, '', CSSs );
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
   C, T :Integer;
begin
     Result := '';  C := 0;  T := 0;

     for V in _Vars do Result := Result + V.GetSource( C, T );
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

/////////////////////////////////////////////////////////////////////// メソッド

procedure TLuxMaterial.DoInitialize;
begin
     inherited;

end;

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
