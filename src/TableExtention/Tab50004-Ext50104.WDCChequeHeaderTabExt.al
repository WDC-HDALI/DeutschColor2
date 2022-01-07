tableextension 50104 "WDC ChequeHeaderTabExt" extends "Cheque Header" //50004
{
    fields
    {
        field(50200; "Code Status"; Code[20])
        {
            TableRelation = "WDC payment status";
            DataClassification = ToBeClassified;
            Editable = False;
        }

        field(50202; "Description Status"; Text[100])
        {
            Editable = False;
            FieldClass = FlowField;
            CalcFormula = lookup("WDC payment status"."Description Status" where("Code Status" = field("Code Status")));
        }
        field(50203; "Cheque Generated"; Boolean)
        {
            Editable = False;
        }

    }

}