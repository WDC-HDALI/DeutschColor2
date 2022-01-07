pageextension 50105 "WDCChequeCardPagExt" extends "Cheque Card" //50006
{
    layout
    {
        addafter(Status)
        {

            field("Description Status"; Rec."Description Status")
            {
                ApplicationArea = All;
            }
            field("Cheque Generated"; Rec."Cheque Generated")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

        addafter("General Ledger Entries")
        {
            action("Generate Cheque")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CreateLedgerBudget;
                trigger OnAction()
                var
                    ltext0001: label 'Value cheque must be not null ';
                    ltext0002: label 'Are you sure to generate the current cheque';
                    ltext0003: label 'Cheque is already Generated';
                    ltext0004: label 'Please check the due date of cheque';
                    ltext0005: label 'Please check the starting date of cheque';
                    ltext0006: label 'Must input an invoice in cheque lines';
                    lchequeLines: record "Cheque Line";

                begin
                    Rec.TestField("Customer No.");
                    If rec."Cheque Value" = 0 then
                        error(ltext0001);
                    If rec."Due Date" = 0D then
                        Error(ltext0004);
                    If rec."Starting Date" = 0D then
                        Error(ltext0005);
                    If Rec."Cheque Generated" then
                        Error(ltext0003);
                    if rec."Cheque Value" = 0 Then
                        lchequeLines.Reset();
                    lchequeLines.SetRange("Cheque No.", rec."Cheque No.");
                    if lchequeLines.IsEmpty Then
                        Error(ltext0006);
                    If Not Confirm(Ltext0002) THEN
                        exit;
                    GenerateCheque;
                end;
            }
        }

    }
    procedure GenerateCheque()
    Var
        lGenjournalLine: record "Gen. Journal Line";
        lpaymentStatus: Record 50100;
        lBatchName: record 232;
        ltext0001: label 'Cheque genereted';
        lchequeHeader: record "Cheque Header";

    begin

        lGenjournalLine.Init();
        lGenjournalLine."Journal Template Name" := 'PAYMENTS';
        lGenjournalLine."Source Code" := 'PAYMENTJNL';
        lGenjournalLine.InitNewLine(WorkDate, WorkDate, '', '', '', 0, '');
        lGenjournalLine.validate("Document Type", lGenjournalLine."Document Type"::Payment);
        lGenjournalLine.validate("Account Type", lGenjournalLine."Account Type"::Customer);
        If Rec."Cheque/Traite" = Rec."Cheque/Traite"::Cheque THEN begin
            lGenjournalLine."Journal Batch Name" := SelectBatcNameFromPaymentStatus(lGenjournalLine."Payment Type"::Cheque);
            lGenjournalLine."Line No." := WDC_GetNewLineNo('PAYMENTS', SelectBatcNameFromPaymentStatus(lGenjournalLine."Payment Type"::Cheque));
            lBatchName.Reset();
            lBatchName.SetRange("Payment Type", lGenjournalLine."Payment Type"::Cheque);
            lBatchName.SetRange("First Step of Cheque", true);
            if lBatchName.FindFirst() then begin
                lGenjournalLine."Account Type" := lBatchName."Account Type";
                lGenjournalLine."Bal. Account No." := lBatchName."Bal. Account No.";
            end;
        END ELSE BEGIN
            lGenjournalLine."Journal Batch Name" := SelectBatcNameFromPaymentStatus(lGenjournalLine."Payment Type"::Traite);
            lGenjournalLine."Line No." := WDC_GetNewLineNo('PAYMENTS', SelectBatcNameFromPaymentStatus(lGenjournalLine."Payment Type"::Traite));
            lBatchName.Reset();
            lBatchName.SetRange("Payment Type", lGenjournalLine."Payment Type"::Traite);
            lBatchName.SetRange("First Step of Cheque", true);
            if lBatchName.FindFirst() then begin
                lGenjournalLine."Account Type" := lBatchName."Account Type";
                lGenjournalLine."Bal. Account No." := lBatchName."Bal. Account No.";
            end;
        END;

        If lGenjournalLine.Insert then begin
            lGenjournalLine.Validate("Cheque No.", Rec."Cheque No.");
            IF lGenjournalLine.Modify THEN begin
                If lchequeHeader.Get(Rec."Cheque No.") then begin
                    lchequeHeader."Cheque Generated" := true;
                    lchequeHeader.Modify;
                end;
            end;
            Clear(lGenjournalLine);
            Message(ltext0001);
            CurrPage.Update();
        end;
    end;

    procedure SelectBatcNameFromPaymentStatus(pPaymentType: Enum "WDC Payment Type"): code[20]
    var
        lBatchName: Record 232;
        ltext0001: Label 'There is no payment batch name configured for the step: doc to sales person ';
    begin
        lBatchName.Reset();
        lBatchName.SetRange("Payment Type", pPaymentType);
        lBatchName.SetRange("First Step of Cheque", true);
        if lBatchName.FindFirst() then
            Exit(lBatchName.Name)
        else
            Error(ltext0001);
    end;


    procedure WDC_GetNewLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        if GenJournalLine.FindLast then
            exit(GenJournalLine."Line No." + 10000);
        exit(10000);
    end;

}