program VolumeRender;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  LUX.D3.V4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.V4.pas',
  LUX.D4.M4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D4.M4.pas',
  LUX.D4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D4.pas',
  LUX.D4.V4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D4.V4.pas',
  LUX.M2 in '_LIBRARY\LUXOPHIA\LUX\LUX.M2.pas',
  LUX.M3 in '_LIBRARY\LUXOPHIA\LUX\LUX.M3.pas',
  LUX.M4 in '_LIBRARY\LUXOPHIA\LUX\LUX.M4.pas',
  LUX in '_LIBRARY\LUXOPHIA\LUX\LUX.pas',
  LUX.D1 in '_LIBRARY\LUXOPHIA\LUX\LUX.D1.pas',
  LUX.D2.M4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.M4.pas',
  LUX.D2 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.pas',
  LUX.D2.V4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.V4.pas',
  LUX.D3.M4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.M4.pas',
  LUX.D3 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.pas',
  LUX.FMX.Objects3D in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.Objects3D.pas',
  LUX.FMX in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.pas',
  LIB.Material in '_LIBRARY\LIB.Material.pas',
  LUX.FMX.Material in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.Material.pas',
  LUX.FMX.Types3D in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.Types3D.pas',
  LUX.FMX.Context.DX11 in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.Context.DX11.pas',
  LUX.Data.Octree in '_LIBRARY\LUXOPHIA\LUX\Data\LUX.Data.Octree.pas',
  LUX.Data.Tree in '_LIBRARY\LUXOPHIA\LUX\Data\LUX.Data.Tree.pas',
  LUX.Data.Octree.Atom in '_LIBRARY\LUXOPHIA\LUX\Data\LUX.Data.Octree.Atom.pas',
  LUX.Data.Lattice.T2 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\LUX.Data.Lattice.T2.pas',
  LUX.Data.Lattice.T3 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\LUX.Data.Lattice.T3.pas',
  LUX.Data.Lattice.T1 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\LUX.Data.Lattice.T1.pas',
  LUX.Data.Lattice.T1.D1 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\T1\LUX.Data.Lattice.T1.D1.pas',
  LUX.Data.Lattice.T2.D1 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\T2\LUX.Data.Lattice.T2.D1.pas',
  LUX.Data.Lattice.T3.D3 in '_LIBRARY\LUXOPHIA\LUX\Data\Lattice\T3\LUX.Data.Lattice.T3.D3.pas',
  LUX.FMX.Forms in '_LIBRARY\LUXOPHIA\LUX\FMX\LUX.FMX.Forms.pas',
  LUX.Curve.T1.D3 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T1.D3.pas',
  LUX.Curve.T2.D1 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T2.D1.pas',
  LUX.Curve.T2.D2 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T2.D2.pas',
  LUX.Curve.T2.D3 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T2.D3.pas',
  LUX.Curve.T1.D1 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T1.D1.pas',
  LUX.Curve.T1.D2 in '_LIBRARY\LUXOPHIA\LUX\Curve\LUX.Curve.T1.D2.pas',
  LUX.D5 in '_LIBRARY\LUXOPHIA\LUX\LUX.D5.pas',
  LUX.DN in '_LIBRARY\LUXOPHIA\LUX\LUX.DN.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
