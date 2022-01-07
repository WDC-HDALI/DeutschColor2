tableextension 50100 "WDC GenJournalLineTabExt" extends "Gen. Journal Line" //81
{
    fields
    {
        field(50200; "Code Status"; Code[20])
        {
            TableRelation = "WDC payment status";
            DataClassification = ToBeClassified;
        }
        field(50201; "Payment Type"; Enum "WDC Payment Type")
        {
            DataClassification = ToBeClassified;
        }
        field(50202; "Description Status"; Text[100])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50203; "Cheque No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cheque Header";
            trigger OnValidate()
            var
                lBatchName: Record 232;
                lCHQHeader: Record "Cheque Header";
            begin
                checkbatchName("Cheque No.");
                Clear("Code Status");
                Clear("Payment Type");
                Clear("Description Status");
                Clear("Customer No.");
                Clear("Sales person No.");
                //Clear("Document No.");
                IF lBatchName.Get(rec."Journal Template Name", Rec."Journal Batch Name") then begin
                    "Code Status" := lBatchName."Code Status";
                    "Payment Type" := lBatchName."Payment Type";
                    "Description Status" := lBatchName."Description Status";
                end;
                IF lCHQHeader.Get("Cheque No.") then begin
                    Rec.validate("Customer No.", lCHQHeader."Customer No.");
                    Rec.validate(Rec."Credit Amount", lCHQHeader."Cheque Value");
                    If ("Account Type" = "Account Type"::Customer) or (rec."Source Type" = rec."Source Type"::Customer) then begin
                        "Account No." := lCHQHeader."Customer No.";
                        if "Document No." = '' then
                            "Document No." := "Cheque No.";
                    end;

                end;


            end;
        }
        field(50204; "Customer No."; Code[20])
        {
            TableRelation = Customer;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                lCustumer: Record Customer;
            begin
                Clear("Sales person No.");
                IF lCustumer.GET("Customer No.") THEN
                    "Sales person No." := lCustumer."Salesperson Code";
            end;

        }
        field(50205; "Sales person No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }

    }
    Procedure checkbatchName(pChequeNo: Code[20])
    var
        lBatchName: Record 232;
        lchequeHeader: Record "Cheque Header";
        lText001: label 'Batch name status code is incompatible with the check';
        lText002: label 'The current status of this cheque is the same as %1  ';

    begin
        if lchequeHeader.Get(pChequeNo) then
            if lBatchName.Get(Rec."Journal Template Name", Rec."Journal Batch Name") then begin
                if ((lchequeHeader."Code Status" = '') and (Not lBatchName."First Step of cheque")) or
                   ((lchequeHeader."Code Status" <> '') and (lBatchName."First Step of cheque")) then
                    Error(lText001)
                Else
                    If (lchequeHeader."Code Status" = Rec."Code Status") and (Not lBatchName."First Step of cheque") Then
                        Error(lText002, lBatchName."Code Status")
            end;
    end;

}