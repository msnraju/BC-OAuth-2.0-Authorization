codeunit 50100 "OAuth 2.0 Authorization"
{
    Access = Internal;

    procedure AcquireTokenByRefreshToken(
        TokenEndpointURL: Text;
        ClientId: Text;
        ClientSecret: Text;
        RedirectURL: Text;
        RefreshToken: Text;
        JAccessToken: JsonObject): Boolean
    var
        DotNetUriBuilder: Codeunit DotNet_Uri;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ContentText: Text;
        ResponseText: Text;
        IsSuccess: Boolean;
    begin
        ContentText := 'grant_type=refresh_token' +
            '&refresh_token=' + DotNetUriBuilder.EscapeDataString(RefreshToken) +
            '&redirect_uri=' + DotNetUriBuilder.EscapeDataString(RedirectURL) +
            '&client_id=' + DotNetUriBuilder.EscapeDataString(ClientId) +
            '&client_secret=' + DotNetUriBuilder.EscapeDataString(ClientSecret);
        Content.WriteFrom(ContentText);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method := 'POST';
        Request.SetRequestUri(TokenEndpointURL);
        Request.Content(Content);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                if Response.Content.ReadAs(ResponseText) then
                    IsSuccess := JAccessToken.ReadFrom(ResponseText);
            end else
                if Response.Content.ReadAs(ResponseText) then
                    JAccessToken.ReadFrom(ResponseText);

        exit(IsSuccess);
    end;

    [TryFunction]
    procedure AcquireTokenByAuthorizationCode(
        ClientId: Text;
        ClientSecret: Text;
        AuthorizationURL: Text;
        AccessTokenURL: Text;
        RedirectURL: Text;
        ResourceURL: Text;
        Scope: Text;
        PromptInteraction: Enum "Prompt Interaction";
        var IsSuccess: Boolean;
        JAccessToken: JsonObject)
    var
        OAuth20ConsentDialog: Page "OAuth 2.0 Consent Dialog";
        AuthRequestURL: Text;
        AuthCode: Text;
        State: Text;
    begin
        State := Format(CreateGuid(), 0, 4);

        AuthRequestURL := GetAuthRequestURL(
            ClientId,
            ClientSecret,
            AuthorizationURL,
            RedirectURL,
            State,
            Scope,
            ResourceURL,
            PromptInteraction);

        if AuthRequestURL = '' then
            exit;

        OAuth20ConsentDialog.SetOAuth2CodeFlowGrantProperties(AuthRequestURL, State);
        OAuth20ConsentDialog.RunModal();

        AuthCode := OAuth20ConsentDialog.GetAuthCode();
        if AuthCode <> '' then
            IsSuccess := AcquireTokenByAuthorizationCodeWithCredentials(
                AuthCode,
                ClientId,
                ClientSecret,
                RedirectURL,
                AccessTokenURL,
                JAccessToken);
    end;

    local procedure AcquireTokenByAuthorizationCodeWithCredentials(
        AuthorizationCode: Text;
        ClientId: Text;
        ClientSecret: Text;
        RedirectURL: Text;
        TokenEndpointURL: Text;
        JAccessToken: JsonObject): Boolean;
    var
        DotNetUriBuilder: Codeunit DotNet_Uri;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ContentText: Text;
        ResponseText: Text;
        IsSuccess: Boolean;
    begin
        ContentText := 'grant_type=authorization_code' +
            '&code=' + DotNetUriBuilder.EscapeDataString(AuthorizationCode) +
            '&redirect_uri=' + DotNetUriBuilder.EscapeDataString(RedirectURL) +
            '&client_id=' + DotNetUriBuilder.EscapeDataString(ClientId) +
            '&client_secret=' + DotNetUriBuilder.EscapeDataString(ClientSecret);
        Content.WriteFrom(ContentText);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method := 'POST';
        Request.SetRequestUri(TokenEndpointURL);
        Request.Content(Content);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                if Response.Content.ReadAs(ResponseText) then
                    IsSuccess := JAccessToken.ReadFrom(ResponseText);
            end else
                if Response.Content.ReadAs(ResponseText) then
                    JAccessToken.ReadFrom(ResponseText);

        exit(IsSuccess);
    end;

    procedure GetOAuthProperties(AuthorizationCode: Text; var CodeOut: Text; var StateOut: Text)
    begin
        if AuthorizationCode = '' then begin
            exit;
        end;

        ReadAuthCodeFromJson(AuthorizationCode);
        CodeOut := GetPropertyFromCode(AuthorizationCode, 'code');
        StateOut := GetPropertyFromCode(AuthorizationCode, 'state');
    end;

    local procedure GetAuthRequestURL(
        ClientId: Text;
        ClientSecret: Text;
        AuthRequestURL: Text;
        RedirectURL: Text;
        State: Text;
        Scope: Text;
        ResourceURL: Text;
        PromptConsent: Enum "Prompt Interaction"): Text
    begin
        if (ClientId = '') or (RedirectURL = '') or (state = '') then
            exit('');

        AuthRequestURL := AuthRequestURL + '?' +
            'client_id=' + ClientId +
            '&redirect_uri=' + RedirectURL +
            '&state=' + State +
            '&scope=' + Scope +
            '&response_type=code';

        case PromptConsent of
            PromptConsent::Login:
                AuthRequestURL := AuthRequestURL + '&prompt=login';
            PromptConsent::"Select Account":
                AuthRequestURL := AuthRequestURL + '&prompt=select_account';
            PromptConsent::Consent:
                AuthRequestURL := AuthRequestURL + '&prompt=consent';
            PromptConsent::"Admin Consent":
                AuthRequestURL := AuthRequestURL + '&prompt=admin_consent';
        end;

        if ResourceURL <> '' then
            AuthRequestURL := AuthRequestURL + '&resource=' + ResourceURL;

        exit(AuthRequestURL);
    end;

    local procedure ReadAuthCodeFromJson(var AuthorizationCode: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if not JObject.ReadFrom(AuthorizationCode) then
            exit;

        if not JObject.Get('code', JToken) then
            exit;

        if not JToken.IsValue() then
            exit;

        if not JToken.WriteTo(AuthorizationCode) then
            exit;

        AuthorizationCode := AuthorizationCode.TrimStart('"').TrimEnd('"');
    end;

    local procedure GetPropertyFromCode(CodeTxt: Text; Property: Text): Text
    var
        PosProperty: Integer;
        PosValue: Integer;
        PosEnd: Integer;
    begin
        PosProperty := StrPos(CodeTxt, Property);
        if PosProperty = 0 then
            exit('');

        PosValue := PosProperty + StrPos(CopyStr(Codetxt, PosProperty), '=');
        PosEnd := PosValue + StrPos(CopyStr(CodeTxt, PosValue), '&');

        if PosEnd = PosValue then
            exit(CopyStr(CodeTxt, PosValue, StrLen(CodeTxt) - 1));

        exit(CopyStr(CodeTxt, PosValue, PosEnd - PosValue - 1));
    end;
}