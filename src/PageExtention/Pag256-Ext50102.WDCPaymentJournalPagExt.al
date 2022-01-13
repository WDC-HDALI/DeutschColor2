pageextension 50102 "WDC PaymentJournalPagExt" extends "Payment Journal" //256
{
    layout
    {
        addbefore("Currency Code")
        {
            field("Posting Group"; Rec."Posting Group")
            {
                Editable = true;
                ApplicationArea = All;
            }
            field("Cheque No."; Rec."Cheque No.")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                    lBatchName: Record 232;
                    lCHQHeader: Record "Cheque Header";
                begin
                    Rec.checkbatchName(Rec."Cheque No.");
                    If Rec."Cheque No." <> '' then begin
                        If Rec."Document No." = '' then
                            Rec."Document No." := Rec."Cheque No.";
                    end;
                end;
            }
            field("Customer No."; Rec."Customer No.")
            {
                ApplicationArea = All;
            }
            field("Sales person No."; Rec."Sales person No.")
            {
                ApplicationArea = All;
            }
            field("Code Status"; Rec."Code Status")
            {
                ApplicationArea = All;
            }
            field("payment Type"; Rec."payment Type")
            {
                ApplicationArea = All;
            }
            field("Description Status"; Rec."Description Status")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {

    }
}