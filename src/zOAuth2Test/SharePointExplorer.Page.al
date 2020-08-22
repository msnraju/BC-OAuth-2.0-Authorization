page 50110 "SharePoint Explorer"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "SharePoint File";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Name"; Rec.Name)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        if WebUrl <> '' then
                            Hyperlink(WebUrl);
                    end;
                }
                field("Is Folder"; Rec."Is Folder")
                {
                    ApplicationArea = All;
                }
                field("Size"; Rec.Size)
                {
                    ApplicationArea = All;
                }
                field("Last Modified DateTime"; Rec."Last Modified DateTime")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action("Get OneDrive Root")
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         TempOneDriveFile: Record "SharePoint File" temporary;
            //         OAuth2TokenHelper: Codeunit "OAuth2 Token Helper";
            //         JContent: JsonObject;
            //         JToken: JsonToken;
            //     begin
            //         JContent := OAuth2TokenHelper.GetOneDriveFiles();
            //         if JContent.Get('value', JToken) then
            //             ReadFolders(JToken.AsArray(), TempOneDriveFile);

            //         Rec.Copy(TempOneDriveFile, true);
            //         Rec.FindFirst();
            //     end;
            // }
        }
    }

    local procedure ReadFolders(JsonFolders: JsonArray; var TempOneDriveFile: Record "SharePoint File" temporary)
    var
        JToken: JsonToken;

    begin
        foreach JToken in JsonFolders do
            ReadFolder(JToken.AsObject(), TempOneDriveFile);
    end;

    local procedure ReadFolder(JsonFolder: JsonObject; var TempOneDriveFile: Record "SharePoint File" temporary)
    var
        JObject: JsonObject;
        JToken, JPropToken : JsonToken;
    begin
        TempOneDriveFile.Init();
        if JsonFolder.Get('id', JToken) then
            TempOneDriveFile.Id := JToken.AsValue().AsText();
        if JsonFolder.Get('name', JToken) then
            TempOneDriveFile.Name := JToken.AsValue().AsText();
        if JsonFolder.Get('webUrl', JToken) then
            TempOneDriveFile.WebUrl := JToken.AsValue().AsText();
        if JsonFolder.Get('webUrl', JToken) then
            TempOneDriveFile.WebUrl := JToken.AsValue().AsText();
        if JsonFolder.Get('size', JToken) then
            TempOneDriveFile.Size := JToken.AsValue().AsInteger();
        if JsonFolder.Get('lastModifiedDateTime', JToken) then
            TempOneDriveFile."Last Modified DateTime" := JToken.AsValue().AsDateTime();
        if JsonFolder.Get('folder', JPropToken) then
            TempOneDriveFile."Is Folder" := true;
        TempOneDriveFile.Insert;
    end;
}
