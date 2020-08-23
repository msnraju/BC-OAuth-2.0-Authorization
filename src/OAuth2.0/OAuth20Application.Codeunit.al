codeunit 50101 "OAuth 2.0 App. Helper"
{
    var
        OAuth2Authorization: Codeunit "OAuth 2.0 Authorization";

    procedure RequestAccessToken(var Application: Record "OAuth 2.0 Application"; var MessageTxt: Text): Boolean
    var
        IsSuccess: Boolean;
        JAccessToken: JsonObject;
        RefreshToken: Text;
        ElapsedSecs: Integer;
    begin
        if Application.Status = Application.Status::Connected then begin
            ElapsedSecs := Round((CurrentDateTime() - Application."Authorization Time") / 1000, 1, '>');
            if ElapsedSecs < Application."Expires In" then
                exit(true)
            else
                if RefreshAccessToken(Application, MessageTxt) then
                    exit(true);
        end;

        Application."Authorization Time" := CurrentDateTime();
        IsSuccess := OAuth2Authorization.AcquireAuthorizationToken(
            Application."Grant Type",
            Application."User Name",
            Application.Password,
            Application."Client ID",
            Application."Client Secret",
            Application."Authorization URL",
            Application."Access Token URL",
            Application."Redirect URL",
            Application."Auth. URL Parms",
            Application.Scope,
            JAccessToken);

        if IsSuccess then begin
            ReadTokenJson(Application, JAccessToken);
            Application.Status := Application.Status::Connected;
        end else begin
            MessageTxt := GetErrorDescription(JAccessToken);
            Application.Status := Application.Status::Error;
        end;

        Application.Modify();
        exit(IsSuccess);
    end;

    procedure RefreshAccessToken(var Application: Record "OAuth 2.0 Application"; var MessageTxt: Text): Boolean
    var
        JAccessToken: JsonObject;
        RefreshToken: Text;
        IsSuccess: Boolean;
    begin
        RefreshToken := GetRefreshToken(Application);
        if RefreshToken = '' then
            exit;

        Application."Authorization Time" := CurrentDateTime();
        IsSuccess := OAuth2Authorization.AcquireTokenByRefreshToken(
            Application."Access Token URL",
            Application."Client ID",
            Application."Client Secret",
            Application."Redirect URL",
            RefreshToken,
            JAccessToken);

        if IsSuccess then begin
            ReadTokenJson(Application, JAccessToken);
            Application.Status := Application.Status::Connected;
        end else begin
            MessageTxt := GetErrorDescription(JAccessToken);
            Application.Status := Application.Status::Error;
        end;

        Application.Modify();
        exit(IsSuccess);
    end;

    procedure GetAccessToken(var Application: Record "OAuth 2.0 Application"): Text
    var
        IStream: InStream;
        Buffer: TextBuilder;
        Line: Text;
    begin
        Application.CalcFields("Access Token");
        if Application."Access Token".HasValue then begin
            Application."Access Token".CreateInStream(IStream, TextEncoding::UTF8);
            while not IStream.EOS do begin
                IStream.ReadText(Line, 1024);
                Buffer.Append(Line);
            end;
        end;

        exit(Buffer.ToText())
    end;

    procedure GetRefreshToken(var Application: Record "OAuth 2.0 Application"): Text
    var
        IStream: InStream;
        Buffer: TextBuilder;
        Line: Text;
    begin
        Application.CalcFields("Refresh Token");
        if Application."Refresh Token".HasValue then begin
            Application."Refresh Token".CreateInStream(IStream, TextEncoding::UTF8);
            while not IStream.EOS do begin
                IStream.ReadText(Line, 1024);
                Buffer.Append(Line);
            end;
        end;

        exit(Buffer.ToText())
    end;

    local procedure GetErrorDescription(JAccessToken: JsonObject): Text
    var
        JToken: JsonToken;
    begin
        if (JAccessToken.Get('error_description', JToken)) then
            exit(JToken.AsValue().AsText());
    end;

    local procedure ReadTokenJson(var Application: Record "OAuth 2.0 Application"; JAccessToken: JsonObject)
    var
        TempBlob: Codeunit "Temp Blob";
        JToken: JsonToken;
        Property: Text;
        OStream: OutStream;
    begin
        foreach Property in JAccessToken.Keys() do begin
            JAccessToken.Get(Property, JToken);
            case Property of
                'token_type',
                'scope':
                    ;
                'expires_in':
                    Application."Expires In" := JToken.AsValue().AsInteger();
                'ext_expires_in':
                    Application."Ext. Expires In" := JToken.AsValue().AsInteger();
                'access_token':
                    begin
                        Application."Access Token".CreateOutStream(OStream, TextEncoding::UTF8);
                        OStream.WriteText(JToken.AsValue().AsText());
                    end;
                'refresh_token':
                    begin
                        Application."Refresh Token".CreateOutStream(OStream, TextEncoding::UTF8);
                        OStream.WriteText(JToken.AsValue().AsText());
                    end;
                else
                    Error('Invalid Access Token Property %1, Value:  %2', Property, JToken.AsValue().AsText());
            end;
        end;
    end;
}