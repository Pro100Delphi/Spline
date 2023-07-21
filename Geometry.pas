unit Geometry;

interface

uses
  D2D1;

type
  TGeometry = class
    private
      FTransform: TD2DMatrix3x2F;

      FGeometry: ID2D1Geometry;
      FName: String;

      FPos: D2D_POINT_2F;
      FLineColor: TD3DColorValue;
      FFillColor: TD3DColorValue;

    public
    	constructor Create; virtual;
      destructor Destroy; override;

      procedure Move(APos: D2D_POINT_2F);

      property Transform: TD2DMatrix3x2F read FTransform write FTransform;
      property Geometry: ID2D1Geometry read FGeometry write FGeometry;
      property Name: String read FName write FName;

      property Pos: D2D_POINT_2F read FPos write FPos;

      property LineColor: TD3DColorValue read FLineColor write FLineColor;
      property FillColor: TD3DColorValue read FFillColor write FFillColor;
  end;

implementation

{ TGeometry }

constructor TGeometry.Create;
begin
  FTransform := TD2DMatrix3x2F.Identity;
  FGeometry := nil;

  FLineColor := D2D1ColorF(1, 0, 0, 1);
	FFillColor := D2D1ColorF(1, 0.7, 0.5, 1);
end;

destructor TGeometry.Destroy;
begin

  inherited;
end;

procedure TGeometry.Move(APos: D2D_POINT_2F);
begin
  FTransform := TD2DMatrix3x2F.Translation(APos);
end;

end.
