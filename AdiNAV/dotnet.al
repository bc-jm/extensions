dotnet
{
    assembly("mscorlib")
    {
        type("System.IO.File") { }
        type("System.Text.Encoding") { }
        type("System.Array") { }
        type("System.Convert") { }
        type("System.IO.StreamReader") { }
        type("System.IO.Path") { }
        type("System.IO.FileStream"; "FileStream") { }
        type("System.IO.FileMode"; "FileMode") { }
        type("System.String") { }
        type("System.IO.StreamWriter") { }
        type("System.Text.UTF8Encoding") { }
        type("System.IO.StringReader") { }
    }

    assembly("System")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Collections.Generic.SortedDictionary`2"; "SortedDictionary_Of_T_U") { }
        type("System.Uri") { }
    }

    assembly("")
    {
        type(""; "") { }
    }

    assembly("System.Net.Http")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b03f5f7f11d50a3a';

        type("System.Net.Http.HttpResponseMessage"; "HttpResponseMessage") { }
        type("System.Net.Http.HttpClient"; "HttpClient") { }
        type("System.Net.Http.HttpContent"; "HttpContent") { }
        type("System.Net.Http.Headers.AuthenticationHeaderValue"; "AuthenticationHeaderValue") { }
        type("System.Net.Http.StringContent"; "StringContent") { }
    }

    assembly("System.Xml")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Xml.XmlNode") { }
        type("System.Xml.XmlDocument") { }
        type("System.Xml.XmlNodeList") { }
        type("System.Xml.XmlAttributeCollection"; "XmlAttributeCollection") { }
        type("System.Xml.XmlNamespaceManager") { }
        type("System.Xml.XmlNameTable"; "XmlNameTable") { }
        type("System.Xml.XmlReaderSettings") { }
        type("System.Xml.XmlTextReader") { }
    }

    assembly("System.Web")
    {
        Version = '2.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b03f5f7f11d50a3a';

        type("System.Web.HttpUtility"; "HttpUtility") { }
    }

}
