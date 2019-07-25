page 75004 "Adiuto Pass. Cycle Electr.Doc."
{
    // version ADI.003

    UsageCategory = Lists;
    Caption = 'Adiuto Import Electr. Doc. List';
    CardPageID = "Adiuto Electr. Doc. Temp. Card";
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Electr. Doc. Temp. Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = gBlnEditable;
                field("Document Type"; "Document Type")
                {
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                }
                field("Buy-from Vendor Name 2"; "Buy-from Vendor Name 2")
                {
                }
                field("Buy-from Address"; "Buy-from Address")
                {
                }
                field("Buy-from Address 2"; "Buy-from Address 2")
                {
                }
                field("Buy-from City"; "Buy-from City")
                {
                }
                field("Buy-from Post Code"; "Buy-from Post Code")
                {
                }
                field("Buy-from County"; "Buy-from County")
                {
                }
                field("Buy-from Country/Region Code"; "Buy-from Country/Region Code")
                {
                }
                field("Document Date"; "Document Date")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                }
                field("Vendor Cr. Memo No."; "Vendor Cr. Memo No.")
                {
                }
                field("Check Total"; "Check Total")
                {
                }
                field("XML_2.4.2.5 DataScadPagamento"; "XML_2.4.2.5 DataScadPagamento")
                {
                }
                field("XML_2.4.2.2 ModalitaPagamento"; "XML_2.4.2.2 ModalitaPagamento")
                {
                }
                field("XML_2.4.1 CondizioniPagamento"; "XML_2.4.1 CondizioniPagamento")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field("CIG Code"; "CIG Code")
                {
                }
                field("CUP Code"; "CUP Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Filters)
            {
                Caption = 'Filters';
                action(SelectToConfirm)
                {
                    Caption = 'To Confirm';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        SelectRecord(gOptDocumentStatus::"Da Convertire");
                    end;
                }
                action(SelectConfirmed)
                {
                    Caption = 'To Confirm';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        SelectRecord(gOptDocumentStatus::Convertite);
                    end;
                }
            }
            group("Actions")
            {
                Caption = 'Actions';
            }
            action("Get Electr. Inv. from Adiuto")
            {
                Caption = 'Get Electr. Inv. from Adiuto';
                Image = Web;
                Visible = false;

                trigger OnAction()
                var
                    lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
                begin
                    lCduAdiutoDocuments.AdiutoElectrInvoiceDownloadAll(TRUE);
                end;
            }
            action("Import Electr. Inv. from XML")
            {
                Caption = 'Import Electr. Inv. from XML';
                Image = Import;

                trigger OnAction()
                var
                    lCduAdiutoElectrInvManagement: Codeunit "Adiuto ED Management";
                    Text001: Label 'Import Document from Adiuto?';
                    lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
                begin
                    IF CONFIRM(Text001) THEN BEGIN
                        lCduAdiutoDocuments.AdiutoElectrInvoiceDownloadAll(FALSE);
                        lCduAdiutoElectrInvManagement.AdiutoElectrInvoiceImportProcess(TRUE);
                    END;
                end;
            }
            action("Create Purch. Header")
            {
                Caption = 'Convert Document';
                Image = Completed;

                trigger OnAction()
                var
                    lCduAdiutoElectrInvManagement: Codeunit "Adiuto ED Management";
                    Text001: Label 'Do you want to Convert selected document in Microsoft Dynamics NAV document?';
                    Text002: Label 'Select document to convert';
                    lRecElectrInvTempHeader: Record "Electr. Doc. Temp. Header";
                    Text003: Label 'Select document with the same type';
                    lIntDocumentType: Integer;
                begin
                    IF gOptDocumentStatus <> gOptDocumentStatus::"Da Convertire" THEN
                        ERROR(Text002);

                    IF CONFIRM(Text001) THEN BEGIN
                        lRecElectrInvTempHeader.RESET;
                        CurrPage.SETSELECTIONFILTER(lRecElectrInvTempHeader);
                        IF lRecElectrInvTempHeader.FINDSET THEN BEGIN
                            lIntDocumentType := lRecElectrInvTempHeader."Document Type";
                            REPEAT
                                IF (lIntDocumentType <> lRecElectrInvTempHeader."Document Type") THEN
                                    ERROR(Text003);
                            UNTIL lRecElectrInvTempHeader.NEXT = 0;
                            lRecElectrInvTempHeader.FINDSET;
                        END;

                        lCduAdiutoElectrInvManagement.AdiutoElectrInvoicePreRegisterProcess(lRecElectrInvTempHeader, TRUE);
                    END;
                end;
            }
            group(Adiuto)
            {
                Caption = 'Adiuto';
                action(ADI_ViewDocs)
                {
                    Caption = 'Show Docs';
                    Image = Documents;

                    trigger OnAction()
                    var
                        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
                        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
                        lRefRecordRef: RecordRef;
                    begin
                        //>AdiNAV
                        lCduAdiutoDocuments.ViewDocumentByBarcode(FORMAT(Rec.Barcode));
                        //<AdiNAV
                    end;
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        lRecAdiutoElectrDoc: Record "Adiuto Electr. Doc.";
        lRecAdiutoSetupED: Record "Adiuto Setup ED";
    begin
        IF lRecAdiutoElectrDoc.GET(Rec."Source No.", Rec."Document No.", Rec.IdUnivoco) THEN
            IF lRecAdiutoElectrDoc.Status = lRecAdiutoSetupED."Electr. Doc. Registered Status" THEN
                ERROR(gText001);
    end;

    trigger OnInit()
    begin
        gOptDocumentStatus := gOptDocumentStatus::"Da Convertire";
        gBlnEditable := TRUE;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF NOT gBlnEditable THEN
            ERROR(gText001);
    end;

    trigger OnOpenPage()
    begin
        SelectRecord(gOptDocumentStatus::"Da Convertire");
    end;

    var
        gOptDocumentStatus: Option "Da Convertire",Convertite;
        gBlnEditable: Boolean;
        gText001: Label 'Modify not allowed';

    local procedure SelectRecord(pIntSelection: Integer)
    begin
        gOptDocumentStatus := pIntSelection;
        IF gOptDocumentStatus = gOptDocumentStatus::"Da Convertire" THEN BEGIN
            Rec.RESET;
            Rec.SETRANGE("Reg. Document No.", '');
            Rec.SETRANGE("Reg. Source No.", 0);
            gBlnEditable := TRUE;
        END
        ELSE
            IF gOptDocumentStatus = gOptDocumentStatus::Convertite THEN BEGIN
                Rec.RESET;
                Rec.SETFILTER("Reg. Document No.", '<>%1', '');
                Rec.SETFILTER("Reg. Source No.", '<>%1', 0);
                gBlnEditable := FALSE;
            END;
        CurrPage.UPDATE;
    end;
}

