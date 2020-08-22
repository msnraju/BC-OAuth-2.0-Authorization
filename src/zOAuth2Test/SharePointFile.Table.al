table 50110 "SharePoint File"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; Name; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; Size; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; WebUrl; Text[500])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Is Folder"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Last Modified DateTime"; DateTime)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}