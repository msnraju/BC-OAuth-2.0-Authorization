table 50100 "OAuth 2.0 Application"
{
    Caption = 'OAuth 2.0 Application';
    DrillDownPageId = "OAuth 2.0 Applications";
    LookupPageId = "OAuth 2.0 Applications";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "Client ID"; Text[250])
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Client Secret"; Text[250])
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Redirect URL"; Text[250])
        {
            Caption = 'Redirect URL';
        }
        field(6; "Auth. URL Parms"; Text[250])
        {
            Caption = 'Auth. URL Parms';
        }
        field(7; Scope; Text[250])
        {
            Caption = 'Scope';
        }
        field(8; "Authorization URL"; Text[250])
        {
            Caption = 'Authorization URL';

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Authorization URL" <> '' then
                    WebRequestHelper.IsSecureHttpUrl("Authorization URL");
            end;
        }
        field(9; "Access Token URL"; Text[250])
        {
            Caption = 'Access Token URL';

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Access Token URL" <> '' then
                    WebRequestHelper.IsSecureHttpUrl("Access Token URL");
            end;
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Enabled,Disabled,Connected,Error';
            OptionMembers = " ",Enabled,Disabled,Connected,Error;
        }
        field(11; "Access Token"; Blob)
        {
            Caption = 'Access Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Refresh Token"; Blob)
        {
            Caption = 'Refresh Token';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Authorization Time"; DateTime)
        {
            Caption = 'Authorization Time';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Expires In"; Integer)
        {
            Caption = 'Expires In';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Ext. Expires In"; Integer)
        {
            Caption = 'Ext. Expires In';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Grant Type"; Enum "Auth. Grant Type")
        {
            Caption = 'Grant Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "User Name"; Text[80])
        {
            Caption = 'User Name';
        }
        field(18; Password; Text[20])
        {
            Caption = 'Password';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    begin
        Status := Status::" ";
        Clear("Access Token");
        Clear("Refresh Token");
        "Expires In" := 0;
        "Ext. Expires In" := 0;
        "Authorization Time" := 0DT;
    end;
}