page 50101 "OAuth 2.0 Application"
{
    Caption = 'OAuth 2.0 Application';
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "OAuth 2.0 Application";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description.';
                }
                field("Client ID"; "Client ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the client ID.';
                }
                field("Client Secret"; "Client Secret")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the client Secret.';
                }
                field("Redirect URL"; "Redirect URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the redirect URL.';
                }
                field(Scope; Scope)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the scope.';
                }
            }
            group("Request URL Paths")
            {
                Caption = 'Request URL Paths';

                field("Authorization URL Path"; "Authorization URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the authorization URL path.';
                }
                field("Access Token URL Path"; "Access Token URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the access token URL path.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RequestAuthorizationCode)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Request Authorization Code';
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Open the service authorization web page. Login credentials will be prompted. The authorization code must be copied into the Enter Authorization Code field.';

                trigger OnAction()
                var
                    OAuth20Application: Codeunit "OAuth 2.0 Application";
                    MessageTxt: Text;
                begin
                    if not OAuth20Application.RequestAuthorizationCode(Rec, MessageTxt) then begin
                        Commit(); // save new "Status" value
                        Error(MessageTxt);
                    end else
                        Message(SuccessfulMsg);
                end;
            }
            action(RefreshAccessToken)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Access Token';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Refresh the access and refresh tokens.';

                trigger OnAction()
                var
                    OAuth20Application: Codeunit "OAuth 2.0 Application";
                    MessageText: Text;
                begin
                    if not OAuth20Application.RefreshAccessToken(Rec, MessageText) then begin
                        Commit(); // save new "Status" value
                        Error(MessageText);
                    end else
                        Message(SuccessfulMsg);
                end;
            }
        }
        area(navigation)
        {
            action(HttpLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Http Log';
                Image = Log;
                ToolTip = 'See the http request/response history log entries for the current OAuth endpoint setup.';

                trigger OnAction()
                var
                    ActivityLog: Record "Activity Log";
                begin
                    ActivityLog.ShowEntries(Rec);
                end;
            }
        }
    }

    var
        SuccessfulMsg: Label 'Authorization Token updated successfully.';
}

