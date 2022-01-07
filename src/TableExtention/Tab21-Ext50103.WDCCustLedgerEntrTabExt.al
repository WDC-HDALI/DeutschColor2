tableextension 50103 "WDC CustLedgerEntrTabExt" extends "Cust. Ledger Entry" //21
{
    fields
    {

        field(50200; "Code Status"; Code[20])
        {
            TableRelation = "WDC payment status";
            DataClassification = ToBeClassified;
            Editable = False;

        }
        field(50201; "Payment Type"; Enum "WDC Payment Type")
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }
        field(50202; "Description Status"; Text[100])
        {
            Editable = False;
            DataClassification = ToBeClassified;

        }
        field(50203; "Cheque No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }
        field(50204; "Cheque No. Of Invoivce"; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Cheque Line"."Cheque No." where("Invoice No." = field("Document No.")));
        }

        field(50205; "Sales person No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }

    }

}

