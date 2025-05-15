codeunit 50802 "VIC Json Utilities"
{
    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

    procedure SetDateFromJson(JsonToken: JsonToken; TokenKey: Text; var DateToSet: Date)
    var
        JsonTokenDate: JsonToken;
        DateFromRecord: Text;
        DateParts: List of [Text];
    begin
        JsonTokenDate := GetJsonToken(JsonToken.AsObject(), TokenKey);
        if not JsonTokenDate.AsValue().IsNull() then begin
            DateFromRecord := GetJsonToken(JsonToken.AsObject(), TokenKey).AsValue.AsText();
            DateParts := DateFromRecord.Split('T');
            Evaluate(DateToSet, DateParts.Get(1));
        end;
    end;

    procedure GetDecimalFromJson(Token: JsonToken; TokenKey: Text): Decimal
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsDecimal());
    end;

    procedure GetIntegerFromJson(Token: JsonToken; TokenKey: Text): Integer
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsInteger());
    end;

    procedure GetTextFromJson(Token: JsonToken; TokenKey: Text): Text
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsText());
    end;

    procedure GetBooleanFromJson(Token: JsonToken; TokenKey: Text): Boolean
    begin
        Exit(GetJsonToken(Token.AsObject(), TokenKey).AsValue().AsBoolean());
    end;

    procedure GetDateFromJson(Token: JsonToken; TokenKey: Text): DateTime
    var
        DateText: Text;
        // DateParts: List of [Text];
        DateFromJson: DateTime;
    begin
        DateText := GetTextFromJson(Token, TokenKey);

        // Date is expected to be YYYY-MM-DD so we need to remove the time portion.
        // DateParts := DateText.Split('T');
        //        Evaluate(DateFromJson, DateParts.Get(1));

        // 9 means convert from xml format
        Evaluate(DateFromJson, DateText, 9);
        Exit(DateFromJson);
    end;

    procedure CreateJsonObject(): JsonObject
    var
        Json: JsonObject;
    begin
        exit(Json);
    end;

    procedure CreateJsonArray(): JsonArray
    var
        Json: JsonArray;
    begin
        exit(Json);
    end;
}
