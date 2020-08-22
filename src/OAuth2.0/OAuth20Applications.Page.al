page 50100 "OAuth 2.0 Applications"
{
    ApplicationArea = Basic, Suite, Service;
    Caption = 'OAuth2 Setup List';
    CardPageID = "OAuth 2.0 Application";
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "OAuth 2.0 Application";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Code; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }

                // field("No."; "No.")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                // }
                // field(Name; Name)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the customer''s name. This name will appear on all sales documents for the customer.';
                // }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}
