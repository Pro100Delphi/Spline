unit Component;

interface

uses
  SysUtils, Classes, D2D1, Generics.Collections, Math,

  Geometry;

{
  TComponent
  	- SubItem 1: Rectange
    - SubItem 2: Ellipse
}

type
	TComponent = class(TGeometry)
    private
      FList: TObjectList<TGeometry>;
  	public
    	constructor Create; override;
      destructor Destroy; override;

      procedure Reset;

      procedure Explosion(ARadius: Single);
      procedure ExplosionOnce(AId: Integer; ARadius: Single);

      procedure Add(AGeometry: TGeometry);

      property List: TObjectList<TGeometry> read FList;
  end;

implementation

{ TComponent }

constructor TComponent.Create;
begin
  inherited;

  FList := TObjectList<TGeometry>.Create;
end;

destructor TComponent.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

procedure TComponent.Explosion(ARadius: Single);
var G: TGeometry;
		A: Single;
    X, Y: Single;
    N: Single;
begin

	N := 360 / FList.Count;

  A := RandomRange(-20, 20);

  for G in FList do
  	begin
//      A := Random(360);

      X := 0 + ARadius * Cos(A * Pi / 180);
      Y := 0 + ARadius * Sin(A * Pi / 180);

      G.Transform := TD2DMatrix3x2F.Translation(X, Y) * Transform;

      A := A + N + RandomRange(-20, 20);
    end;

end;

procedure TComponent.ExplosionOnce(AId: Integer; ARadius: Single);
var A: Single;
    X, Y: Single;
begin
  A := Random(360);

  X := 0 + ARadius * Cos(A * Pi / 180);
  Y := 0 + ARadius * Sin(A * Pi / 180);

  FList[AId].Transform :=  TD2DMatrix3x2F.Translation(X, Y) * Transform;
end;

procedure TComponent.Reset;
var G: TGeometry;
begin

  for G in FList do
    G.Transform := TD2DMatrix3x2F.Identity;

end;

procedure TComponent.Add(AGeometry: TGeometry);
begin
  FList.Add(AGeometry);
end;

end.
