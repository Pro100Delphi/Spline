unit Core;

interface

uses
  D2D1;

var FFactory: ID2D1Factory;

implementation

initialization
  D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, IID_ID2D1Factory, nil, FFactory);

  ReportMemoryLeaksOnShutdown := True;

end.
