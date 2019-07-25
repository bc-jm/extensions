page 75005 "Adiuto Electr. Doc. Temp. Card"
{
    // version ADI.003

    Caption = 'Adiuto Electr. Doc. Temp. Card';
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Electr. Doc. Temp. Header";

    layout
    {
        area(content)
        {
            group("Document Header")
            {
                Caption = 'Document Header';
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
                field("Buy-from Contact"; "Buy-from Contact")
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
                field("No."; "No.")
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
                field("Currency Code"; "Currency Code")
                {
                }
                field("Electr. Doc.  No."; "Electr. Doc.  No.")
                {
                }
                field("External Document No."; "External Document No.")
                {
                }
                field("CIG Code"; "CIG Code")
                {
                }
                field("CUP Code"; "CUP Code")
                {
                }
            }
            group(Generale)
            {
                Editable = false;
                field(Barcode; Barcode)
                {
                }
            }
            group("XML fields")
            {
                Caption = 'XML fields';
                Editable = false;
                field("XML_1.1.1.1 IdPaese"; "XML_1.1.1.1 IdPaese")
                {
                }
                field("XML_1.1.1.2 IdCodice"; "XML_1.1.1.2 IdCodice")
                {
                }
                field("XML_1.1.2 Progr. Invio"; "XML_1.1.2 Progr. Invio")
                {
                }
                field("XML_1.1.3 FormatoTrasmissione"; "XML_1.1.3 FormatoTrasmissione")
                {
                }
                field("XML_1.1.4 CodiceDestinatario"; "XML_1.1.4 CodiceDestinatario")
                {
                }
                field("XML_1.1.6 PECDestinatario"; "XML_1.1.6 PECDestinatario")
                {
                }
                field("XML_1.2.1.1.1 IdPaese"; "XML_1.2.1.1.1 IdPaese")
                {
                }
                field("XML_1.2.1.1.2 IdCodice"; "XML_1.2.1.1.2 IdCodice")
                {
                }
                field("XML_1.2.1.2 CodiceFiscale"; "XML_1.2.1.2 CodiceFiscale")
                {
                }
                field("XML_1.2.1.3.1 Denominazione"; "XML_1.2.1.3.1 Denominazione")
                {
                }
                field("XML_1.2.1.3.2 Nome"; "XML_1.2.1.3.2 Nome")
                {
                }
                field("XML_1.2.1.3.3 Cognome"; "XML_1.2.1.3.3 Cognome")
                {
                }
                field("XML_1.2.1.3.4 Titolo"; "XML_1.2.1.3.4 Titolo")
                {
                }
                field("XML_1.2.1.3.5 CodEORI"; "XML_1.2.1.3.5 CodEORI")
                {
                }
                field("XML_1.2.2.1 Indirizzo"; "XML_1.2.2.1 Indirizzo")
                {
                }
                field("XML_1.2.2.2 NumeroCivico"; "XML_1.2.2.2 NumeroCivico")
                {
                }
                field("XML_1.2.2.3 CAP"; "XML_1.2.2.3 CAP")
                {
                }
                field("XML_1.2.2.4 Comune"; "XML_1.2.2.4 Comune")
                {
                }
                field("XML_1.2.2.5 Provincia"; "XML_1.2.2.5 Provincia")
                {
                }
                field("XML_1.2.2.6 Nazione"; "XML_1.2.2.6 Nazione")
                {
                }
                field("XML_2.1.1.1 TipoDocumento"; "XML_2.1.1.1 TipoDocumento")
                {
                }
                field("XML_2.1.1.2 Divisa"; "XML_2.1.1.2 Divisa")
                {
                }
                field("XML_2.1.1.3 Data"; "XML_2.1.1.3 Data")
                {
                }
                field("XML_2.1.1.4 Numero"; "XML_2.1.1.4 Numero")
                {
                }
                field("XML_2.1.1.5.1 TipoRitenuta"; "XML_2.1.1.5.1 TipoRitenuta")
                {
                }
                field("XML_2.1.1.5.2 ImportoRitenuta"; "XML_2.1.1.5.2 ImportoRitenuta")
                {
                }
                field("XML_2.1.1.5.3 AliquotaRitenuta"; "XML_2.1.1.5.3 AliquotaRitenuta")
                {
                }
                field("XML_2.1.1.5.4 CausalePagamento"; "XML_2.1.1.5.4 CausalePagamento")
                {
                }
                field("XML_2.1.1.6.1 BolloVirtuale"; "XML_2.1.1.6.1 BolloVirtuale")
                {
                }
                field("XML_2.1.1.6.2 ImportoBollo"; "XML_2.1.1.6.2 ImportoBollo")
                {
                }
                field("XML_2.1.1.9 Imp. Tot. Doc."; "XML_2.1.1.9 Imp. Tot. Doc.")
                {
                }
                field("XML_2.1.1.10 Arrotondamento"; "XML_2.1.1.10 Arrotondamento")
                {
                }
                field("XML_2.1.2.6 CodiceCIG"; "XML_2.1.2.6 CodiceCIG")
                {
                }
                field("XML_2.1.2.7 CodiceCUP"; "XML_2.1.2.7 CodiceCUP")
                {
                }
                field("XML_2.4.1 CondizioniPagamento"; "XML_2.4.1 CondizioniPagamento")
                {
                }
                field("XML_2.4.2.2 ModalitaPagamento"; "XML_2.4.2.2 ModalitaPagamento")
                {
                }
                field("XML_2.4.2.5 DataScadPagamento"; "XML_2.4.2.5 DataScadPagamento")
                {
                }
            }
            group("NAV document conversion")
            {
                Caption = 'NAV document conversion';
                Editable = false;
                field("Reg. Date"; "Reg. Date")
                {
                }
                field("Reg. Time"; "Reg. Time")
                {
                }
                field("Reg. User Name"; "Reg. User Name")
                {
                }
                field("Reg. Source No."; "Reg. Source No.")
                {
                }
                field("Reg. Document No."; "Reg. Document No.")
                {
                }
                field("Reg. Document Type"; "Reg. Document Type")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IF "Reg. Document No." = '' THEN
            gBlnEditable := TRUE
        ELSE
            gBlnEditable := FALSE;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        IF NOT gBlnEditable THEN
            ERROR(gText001);
    end;

    trigger OnInit()
    begin
        gBlnEditable := TRUE;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF NOT gBlnEditable THEN
            ERROR(gText001);
    end;

    var
        gBlnEditable: Boolean;
        gText001: Label 'Modify not allowed';
}

