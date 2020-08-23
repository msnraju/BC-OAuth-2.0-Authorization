codeunit 50110 "OAuth 2.0 Test"
{
    local procedure GetGoogleAccessToken()
    var
        OAuth20Appln: Record "OAuth 2.0 Application";
        OAuth20AppHelper: Codeunit "OAuth 2.0 App. Helper";
        MessageText: Text;
    begin
        OAuth20Appln.Get('GOOGLE');
        if not OAuth20AppHelper.RequestAccessToken(OAuth20Appln, MessageText) then
            Error(MessageText);

        Message('%1', OAuth20AppHelper.GetAccessToken(OAuth20Appln));
    end;
}