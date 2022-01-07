
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


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnafterPostGenJnlLine', '', FALSE, FALSE)]
    // local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)

    // var
    //     lCustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
    // begin
    //     If (GenJournalLine."Cheque No." = '') Then; //AND (GenJournalLine."Code Status" = '') then
    //                                                 //AppliedCustLedger(GenJournalLine, GenJournalLine."Cheque No.")
    //                                                 // Error('ok');
    // end;


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

    procedure AppliedCustLedger(pGenJournalLine: Record "Gen. Journal Line"; pChqNo: Code[20])
    var
        lCustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        lpageApplied: Page 232;
        lCustLedgEntry: Record "Cust. Ledger Entry";
        lChequelines: Record "Cheque Line";
        lGenJNlApply: Codeunit 225;
    begin
        lChequelines.Reset();
        lChequelines.SetRange("Cheque No.", pChqNo);
        If lChequelines.FindFirst() then
            repeat
            // Clear(lpageApplied);
            // lCustLedgEntry.Reset();
            // lCustLedgEntry.SetRange("Document No.", lChequelines."Invoice No.");
            // If lCustLedgEntry.FindFirst Then begin
            //     lpageApplied.SetRecord(lCustLedgEntry);
            //     lpageApplied.SetTableView(lCustLedgEntry);

            //     lpageApplied.SetCustLedgEntry(lCustLedgEntry);
            //     lpageApplied.SetApplyingCustLedgEntry;
            //     //lpageApplied.Run();
            //     lpageApplied.SetCustApplId(false);

            //     Error('ok');
            //end;

            // with pGenJournalLine do begin
            //     lCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
            //     lCustLedgEntry.SetRange("Document No.", lChequelines."Invoice No.");
            //     lCustLedgEntry.SetRange(Open, true);
            //     If lCustLedgEntry.FindFirst() Then Begin
            //         If "Applies-to ID" = '' then
            //             "Applies-to ID" := "Document No.";
            //         lpageApplied.CalcApplnAmount();
            //         //lpageApplied.CalcApplnRemainingAmount(lCustLedgEntry.Amount);
            //         lpageApplied.SetGenJnlLine(pGenJournalLine, FieldNo("Applies-to ID"));
            //         lpageApplied.SetRecord(lCustLedgEntry);
            //         lpageApplied.SetTableView(lCustLedgEntry);
            //         lpageApplied.SetCustApplId(false);
            //     end;
            // End;
            until lChequelines.Next = 0;
    End;


}