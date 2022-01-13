
codeunit 50100 "ST PaymentSubscribers"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GenJnlManagement", 'OnAfterSetName', '', FALSE, FALSE)]
    local procedure OnAfterGetAccounts(var GenJournalLine: Record "Gen. Journal Line"; CurrentJnlBatchName: Code[10])
    var
        lBatchName: record 232;
        lGenJournalLine: record 81;
    begin
        IF Not lBatchName.Get(GenJournalLine."Journal Template Name", CurrentJnlBatchName) then
            Exit;
        lGenJournalLine.Reset();
        lGenJournalLine.SetRange("Journal Batch Name", CurrentJnlBatchName);
        if not lGenJournalLine.FindFirst() then
            Exit;
        repeat
            lGenJournalLine."Code Status" := lBatchName."Code Status";
            lGenJournalLine."Payment Type" := lBatchName."Payment Type";
            lGenJournalLine."Description Status" := lBatchName."Description Status";
            lGenJournalLine.Modify;
        Until lGenJournalLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', FALSE, FALSE)]
    local procedure OnAfterSetupNewLine(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        IF GenJournalLine."Cheque No." <> '' then begin
            GLEntry."Cheque No." := GenJournalLine."Cheque No.";
            GLEntry."Customer No." := GenJournalLine."Customer No.";
            GLEntry."Sales person No." := GenJournalLine."Sales person No.";
            GLEntry."Code Status" := GenJournalLine."Code Status";
            GLEntry."Payment Type" := GenJournalLine."Payment Type";
            GLEntry."Description Status" := GenJournalLine."Description Status";
            SetCHQStatus(GenJournalLine."Cheque No.", GenJournalLine."Code Status");
            SetCustLedgerEntryStatus(GenJournalLine."Cheque No.", GenJournalLine."Code Status", GenJournalLine."Description Status");
        End;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitCustLedgEntry', '', FALSE, FALSE)]
    local procedure OnAfterInitCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    Var

    begin
        IF GenJournalLine."Cheque No." <> '' then begin
            CustLedgerEntry."Cheque No." := GenJournalLine."Cheque No.";
            CustLedgerEntry."Customer No." := GenJournalLine."Customer No.";
            CustLedgerEntry."Sales person No." := GenJournalLine."Sales person No.";
            CustLedgerEntry."Code Status" := GenJournalLine."Code Status";
            CustLedgerEntry."Payment Type" := GenJournalLine."Payment Type";
            CustLedgerEntry."Description Status" := GenJournalLine."Description Status";

        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostGenJnlLine', '', FALSE, FALSE)]
    local procedure OnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)

    var
        lpaymentApply: Codeunit "WDC Payment Aplly";
        lchequeLines: record "Cheque Line";
        lCustLedgerEntry: Record "Cust. Ledger Entry";
        lCustLedgEntry: Record "Cust. Ledger Entry";
        lBatchName: record 232;
    begin
        If (GenJournalLine."Cheque No." <> '') AND StepOfApply(GenJournalLine."Code Status") then begin
            lCustLedgEntry.Reset();
            lCustLedgEntry.SetRange("Document Type", lCustLedgEntry."Document Type"::Payment);
            lCustLedgEntry.SetRange("Document No.", GenJournalLine."Cheque No.");
            if lCustLedgEntry.FindFirst() Then Begin
                lchequeLines.Reset();
                lchequeLines.SetRange("Cheque No.", GenJournalLine."Cheque No.");
                if lchequeLines.FindFirst() then
                    repeat
                        lpaymentApply.ApplyInvoiceEntry_DetCustLedgerEntry(lchequeLines."Invoice No.", lchequeLines."Cheque No.", lCustLedgEntry."Transaction No.");
                        lpaymentApply.ClosedInvoiceCustomerLedgerEntry(lchequeLines."Invoice No.", lCustLedgEntry."Entry No.", lchequeLines."Amount LCY");
                        Message('Facture %1', lchequeLines."Invoice No.");
                    Until lchequeLines.Next = 0;
                Message('Payment %1', GenJournalLine."Document No.");
                lpaymentApply.ApplyPaymentEntry_DetCustLedgerEntry(GenJournalLine."Cheque No.", lCustLedgEntry."Transaction No.");
                lpaymentApply.ClosedPaymentCustomerLedgerEntry(GenJournalLine."Cheque No.");
            End;
        end;
    End;

    procedure StepOfApply(pStatusCode: Code[20]): Boolean
    var
        lBatchName: record 232;
    begin
        lBatchName.Reset();
        lBatchName.SetRange("Code Status", pStatusCode);
        If lBatchName.FindFirst() Then;
        exit(lBatchName."First Step of cheque");
    end;

    procedure SetCHQStatus(pChqNo: Code[20]; "pStatusCode": Code[20])
    var
        lCHQHeader: Record "Cheque Header";
    begin
        If Not lCHQHeader.Get(pChqNo) then
            Exit;
        lCHQHeader."Code Status" := pStatusCode;
        lCHQHeader.Modify;
    end;

    procedure SetCustLedgerEntryStatus(pChqNo: Code[20]; "pStatusCode": Code[20]; pDescriptionStatus: Text[100])
    var
        lCustomerLedgEntry: Record "Cust. Ledger Entry";
    begin
        lCustomerLedgEntry.Reset();
        lCustomerLedgEntry.SetRange("Cheque No.", pChqNo);
        lCustomerLedgEntry.SetRange("Document Type", lCustomerLedgEntry."Document Type"::Payment);
        if lCustomerLedgEntry.FindFirst() then
            repeat
                lCustomerLedgEntry."Code Status" := pStatusCode;
                lCustomerLedgEntry."Description Status" := pDescriptionStatus;
                lCustomerLedgEntry.Modify;
            until lCustomerLedgEntry.Next = 0;
    end;

}