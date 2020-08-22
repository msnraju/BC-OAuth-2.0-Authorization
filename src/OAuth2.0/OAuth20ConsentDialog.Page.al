page 50102 "OAuth 2.0 Consent Dialog"
{
    Extensible = false;
    Caption = 'Waiting for a response - do not close this page';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            usercontrol(OAuthIntegration; "OAuth 2.0 Integration")
            {
                ApplicationArea = All;

                trigger AuthorizationCodeRetrieved(code: Text)
                var
                    StateOut: Text;
                begin
                    OAuth20Authorization.GetOAuthProperties(code, AuthCode, StateOut);

                    if AuthCode = '' then begin
                        AuthCodeError := NoAuthCodeErr;
                    end;
                    if State = '' then begin
                        AuthCodeError := AuthCodeError + NoStateErr;
                    end else
                        if StateOut <> State then begin
                            AuthCodeError := AuthCodeError + NotMatchingStateErr;
                        end;

                    CurrPage.Close();
                end;

                trigger AuthorizationErrorOccurred(error: Text; desc: Text);
                begin
                    AuthCodeError := StrSubstNo(AuthCodeErrorLbl, error, desc);
                    CurrPage.Close();
                end;

                trigger ControlAddInReady();
                begin
                    CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl);
                end;
            }
        }
    }

    procedure SetOAuth2CodeFlowGrantProperties(AuthRequestUrl: Text; AuthInitialState: Text)
    begin
        OAuthRequestUrl := AuthRequestUrl;
        State := AuthInitialState;
    end;

    procedure GetAuthCode(): Text
    begin
        exit(AuthCode);
    end;

    procedure GetAuthCodeError(): Text
    begin
        exit(AuthCodeError);
    end;

    var
        OAuth20Authorization: Codeunit "OAuth 2.0 Authorization";
        OAuthRequestUrl: Text;
        State: Text;
        AuthCode: Text;
        AuthCodeError: Text;
        NoAuthCodeErr: Label 'No authorization code has been returned';
        NoStateErr: Label 'No state has been returned';
        NotMatchingStateErr: Label 'The state parameter value does not match.';
        AuthCodeErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = The authorization error message, %2 = The authorization error description';
}