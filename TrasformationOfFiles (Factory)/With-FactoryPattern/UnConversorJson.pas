unit UnConversorJson;

interface

uses
  System.SysUtils, System.JSON, Data.DB, System.IOUtils,
  Datasnap.DBClient, UnConversorAbs;

type
  TJson = class(TConversorAbs)
    procedure Converter(Const PathFile: string;
      DataSet: TClientDataSet); override;
  end;

implementation

uses
  UnPrincipal;

{ TJson }

procedure TJson.Converter(const PathFile: string; DataSet: TClientDataSet);
var
  ArrayJson: TJSONArray;
  ValorJson: TJSONValue;
  ItemJson: TJSONValue;
  Field: TField;
begin
  inherited;
  DataSet.Close;
  DataSet.Fields.Clear;
  PrincipalConversor.MemoConversorTeste.Lines.Clear;
  ArrayJson := nil;
  try
    ArrayJson := TJsonObject.ParseJSONValue
      (TEncoding.ASCII.GetBytes(TFile.ReadAllText(PathFile)), 0) as TJSONArray;
    if ArrayJson.Count > 0 then
    begin
      ValorJson := ArrayJson.Items[0];
      for ItemJson in TJSONArray(ValorJson) do
      begin
        Field := TWideStringField.Create(DataSet);
        Field.Name := '';
        Field.FieldName := TJSONPair(ItemJson).JsonString.Value;
        Field.DataSet := DataSet;
      end;
    end;

    DataSet.CreateDataSet;

    for ValorJson in ArrayJson do
    begin
      DataSet.Insert;
      for ItemJson in TJSONArray(ValorJson) do
      begin
        DataSet.FieldByName(TJSONPair(ItemJson).JsonString.Value).Value :=
          TJSONPair(ItemJson).JsonValue.Value;
        PrincipalConversor.MemoConversorTeste.Lines.Add
          (TJSONPair(ItemJson).JsonValue.Value);
      end;
      DataSet.Post;
    end;
  finally
    ArrayJson.Free;
  end;
end;

end.
