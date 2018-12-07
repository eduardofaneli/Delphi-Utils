unit JSONUtils;

interface

uses
  System.JSON, Winapi.Windows;

type
  IJSONUtils = interface
    ['{13E2E283-DC11-4B27-A936-51D72C20875E}']
    procedure SetJSONProperty(const Value: TJSONPair);
    function getProperty(const AProperty, AJSON: string): IJSONUtils;
    function getChildProperty(const AParent, AProperty, AJSON: string): IJSONUtils;
    function getValue(): string;
    function getPair(): string;
    function formatJSON(const AJSON: string): IJSONUtils;
    function validateJSON(const AJSON: string): Boolean;
    procedure show(AHandle: HWND);
    property JSONProperty: TJSONPair write SetJSONProperty;
  end;

  TJSONUtils = class(TInterfacedObject, IJSONUtils)
  private
    FJSONProperty: TJSONPair;
    FJSON, FJSONPair: TJSONObject;
    FJSONArray: TJSONArray;
    FHTML: string;
    procedure SetJSONProperty(const Value: TJSONPair);
  public
    function getProperty(const AProperty, AJSON: string): IJSONUtils;
    function getChildProperty(const AParent, AProperty, AJSON: string): IJSONUtils;
    function getValue(): string;
    function getPair(): string;
    function formatJSON(const AJSON: string): IJSONUtils;
    procedure show(AHandle: HWND);
    class function new(): IJSONUtils;
    constructor Create;
    destructor Destroy(); override;
    function validateJSON(const AJSON: string): Boolean;
    property JSONProperty: TJSONPair write SetJSONProperty;
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Forms, Winapi.ShellAPI;

{ TJSONUtils }

constructor TJSONUtils.Create;
begin
  FJSON := TJSONObject.Create;
  FJSONPair := TJSONObject.Create;
end;

destructor TJSONUtils.Destroy;
begin
  FreeAndNil(FJSON);
  FreeAndNil(FJSONPair);
  inherited;
end;

function TJSONUtils.formatJSON(const AJSON: string): IJSONUtils;
var
  html: TStringBuilder;
begin
  html := TStringBuilder.Create;
  try
    FHTML := html.append('<html>')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('<head>')
                 .appendLine()
                 .Append('<title>JSON</title>')
                 .appendLine()
                 .append('    <script>')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('        var module, window, define, renderjson = (function () {')
                 .appendLine()
                 .append('            var themetext = function (/* [class, text]+ */) {')
                 .appendLine()
                 .append('                var spans = [];')
                 .appendLine()
                 .append('                while (arguments.length)')
                 .appendLine()
                 .append('                    spans.push(append(span(Array.prototype.shift.call(arguments)),')
                 .appendLine()
                 .append('                        text(Array.prototype.shift.call(arguments))));')
                 .appendLine()
                 .append('                return spans;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            var append = function (/* el, ... */) {')
                 .appendLine()
                 .append('                var el = Array.prototype.shift.call(arguments);')
                 .appendLine()
                 .append('                for (var a = 0; a < arguments.length; a++)')
                 .appendLine()
                 .append('                    if (arguments[a].constructor == Array)')
                 .appendLine()
                 .append('                        append.apply(this, [el].concat(arguments[a]));')
                 .appendLine()
                 .append('                    else')
                 .appendLine()
                 .append('                        el.appendChild(arguments[a]);')
                 .appendLine()
                 .append('                return el;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            var prepend = function (el, child) {')
                 .appendLine()
                 .append('                el.insertBefore(child, el.firstChild);')
                 .appendLine()
                 .append('                return el;')
                 .appendLine()
                 .append('            }')
                 .appendLine()
                 .append('            var isempty = function (obj, pl) {')
                 .appendLine()
                 .append('                var keys = pl || Object.keys(obj);')
                 .appendLine()
                 .append('                for (var i in keys) if (Object.hasOwnProperty.call(obj, keys[i])) return false;')
                 .appendLine()
                 .append('                return true;')
                 .appendLine()
                 .append('            }')
                 .appendLine()
                 .append('            var text = function (txt) { return document.createTextNode(txt) };')
                 .appendLine()
                 .append('            var div = function () { return document.createElement("div") };')
                 .appendLine()
                 .append('            var span = function (classname) {')
                 .appendLine()
                 .append('                var s = document.createElement("span");')
                 .appendLine()
                 .append('                if (classname) s.className = classname;')
                 .appendLine()
                 .append('                return s;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            var A = function A(txt, classname, callback) {')
                 .appendLine()
                 .append('                var a = document.createElement("a");')
                 .appendLine()
                 .append('                if (classname) a.className = classname;')
                 .appendLine()
                 .append('                a.appendChild(text(txt));')
                 .appendLine()
                 .append('                a.href = ''#'';')
                 .appendLine()
                 .append('                a.onclick = function (e) { callback(); if (e) e.stopPropagation(); return false; };')
                 .appendLine()
                 .append('                return a;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('            function _renderjson(json, indent, dont_indent, show_level, options) {')
                 .appendLine()
                 .append('                var my_indent = dont_indent ? "" : indent;')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                var disclosure = function (open, placeholder, close, type, builder) {')
                 .appendLine()
                 .append('                    var content;')
                 .appendLine()
                 .append('                    var empty = span(type);')
                 .appendLine()
                 .append('                    var show = function () {')
                 .appendLine()
                 .append('                        if (!content) append(empty.parentNode,')
                 .appendLine()
                 .append('                            content = prepend(builder(),')
                 .appendLine()
                 .append('                                A(options.hide, "disclosure",')
                 .appendLine()
                 .append('                                    function () {')
                 .appendLine()
                 .append('                                        content.style.display = "none";')
                 .appendLine()
                 .append('                                        empty.style.display = "inline";')
                 .appendLine()
                 .append('                                    })));')
                 .appendLine()
                 .append('                        content.style.display = "inline";')
                 .appendLine()
                 .append('                        empty.style.display = "none";')
                 .appendLine()
                 .append('                    };')
                 .appendLine()
                 .append('                    append(empty,')
                 .appendLine()
                 .append('                        A(options.show, "disclosure", show),')
                 .appendLine()
                 .append('                        themetext(type + " syntax", open),')
                 .appendLine()
                 .append('                        A(placeholder, null, show),')
                 .appendLine()
                 .append('                        themetext(type + " syntax", close));')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                    var el = append(span(), text(my_indent.slice(0, -1)), empty);')
                 .appendLine()
                 .append('                    if (show_level > 0 && type != "string")')
                 .appendLine()
                 .append('                        show();')
                 .appendLine()
                 .append('                    return el;')
                 .appendLine()
                 .append('                };')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                if (json === null) return themetext(null, my_indent, "keyword", "null");')
                 .appendLine()
                 .append('                if (json === void 0) return themetext(null, my_indent, "keyword", "undefined");')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                if (typeof (json) == "string" && json.length > options.max_string_length)')
                 .appendLine()
                 .append('                    return disclosure(''"'', json.substr(0, options.max_string_length) + " ...", ''"'', "string", function () {')
                 .appendLine()
                 .append('                        return append(span("string"), themetext(null, my_indent, "string", JSON.stringify(json)));')
                 .appendLine()
                 .append('                    });')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                if (typeof (json) != "object" || [Number, String, Boolean, Date].indexOf(json.constructor) >= 0) // Strings, numbers and bools')
                 .appendLine()
                 .append('                    return themetext(null, my_indent, typeof (json), JSON.stringify(json));')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                if (json.constructor == Array) {')
                 .appendLine()
                 .append('                    if (json.length == 0) return themetext(null, my_indent, "array syntax", "[]");')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                    return disclosure("[", options.collapse_msg(json.length), "]", "array", function () {')
                 .appendLine()
                 .append('                        var as = append(span("array"), themetext("array syntax", "[", null, "\n"));')
                 .appendLine()
                 .append('                        for (var i = 0; i < json.length; i++)')
                 .appendLine()
                 .append('                            append(as,')
                 .appendLine()
                 .append('                                _renderjson(options.replacer.call(json, i, json[i]), indent + "    ", false, show_level - 1, options),')
                 .appendLine()
                 .append('                                i != json.length - 1 ? themetext("syntax", ",") : [],')
                 .appendLine()
                 .append('                                text("\n"));')
                 .appendLine()
                 .append('                        append(as, themetext(null, indent, "array syntax", "]"));')
                 .appendLine()
                 .append('                        return as;')
                 .appendLine()
                 .append('                    });')
                 .appendLine()
                 .append('                }')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                // object')
                 .appendLine()
                 .append('                if (isempty(json, options.property_list))')
                 .appendLine()
                 .append('                    return themetext(null, my_indent, "object syntax", "{}");')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('                return disclosure("{", options.collapse_msg(Object.keys(json).length), "}", "object", function () {')
                 .appendLine()
                 .append('                    var os = append(span("object"), themetext("object syntax", "{", null, "\n"));')
                 .appendLine()
                 .append('                    for (var k in json) var last = k;')
                 .appendLine()
                 .append('                    var keys = options.property_list || Object.keys(json);')
                 .appendLine()
                 .append('                    if (options.sort_objects)')
                 .appendLine()
                 .append('                        keys = keys.sort();')
                 .appendLine()
                 .append('                    for (var i in keys) {')
                 .appendLine()
                 .append('                        var k = keys[i];')
                 .appendLine()
                 .append('                        if (!(k in json)) continue;')
                 .appendLine()
                 .append('                        append(os, themetext(null, indent + "    ", "key", ''"'' + k + ''"'', "object syntax", '': ''),')
                 .appendLine()
                 .append('                            _renderjson(options.replacer.call(json, k, json[k]), indent + "    ", true, show_level - 1, options),')
                 .appendLine()
                 .append('                            k != last ? themetext("syntax", ",") : [],')
                 .appendLine()
                 .append('                            text("\n"));')
                 .appendLine()
                 .append('                    }')
                 .appendLine()
                 .append('                    append(os, themetext(null, indent, "object syntax", "}"));')
                 .appendLine()
                 .append('                    return os;')
                 .appendLine()
                 .append('                });')
                 .appendLine()
                 .append('            }')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('            var renderjson = function renderjson(json) {')
                 .appendLine()
                 .append('                var options = new Object(renderjson.options);')
                 .appendLine()
                 .append('                options.replacer = typeof (options.replacer) == "function" ? options.replacer : function (k, v) { return v; };')
                 .appendLine()
                 .append('                var pre = append(document.createElement("pre"), _renderjson(json, "", false, options.show_to_level, options));')
                 .appendLine()
                 .append('                pre.className = "renderjson";')
                 .appendLine()
                 .append('                return pre;')
                 .appendLine()
                 .append('            }')
                 .appendLine()
                 .append('            renderjson.set_icons = function (show, hide) {')
                 .appendLine()
                 .append('                renderjson.options.show = show;')
                 .appendLine()
                 .append('                renderjson.options.hide = hide;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_show_to_level = function (level) {')
                 .appendLine()
                 .append('                renderjson.options.show_to_level = typeof level == "string" &&')
                 .appendLine()
                 .append('                    level.toLowerCase() === "all" ? Number.MAX_VALUE')
                 .appendLine()
                 .append('                    : level;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_max_string_length = function (length) {')
                 .appendLine()
                 .append('                renderjson.options.max_string_length = typeof length == "string" &&')
                 .appendLine()
                 .append('                    length.toLowerCase() === "none" ? Number.MAX_VALUE')
                 .appendLine()
                 .append('                    : length;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_sort_objects = function (sort_bool) {')
                 .appendLine()
                 .append('                renderjson.options.sort_objects = sort_bool;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_replacer = function (replacer) {')
                 .appendLine()
                 .append('                renderjson.options.replacer = replacer;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_collapse_msg = function (collapse_msg) {')
                 .appendLine()
                 .append('                renderjson.options.collapse_msg = collapse_msg;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.set_property_list = function (prop_list) {')
                 .appendLine()
                 .append('                renderjson.options.property_list = prop_list;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            // Backwards compatiblity. Use set_show_to_level() for new code.')
                 .appendLine()
                 .append('            renderjson.set_show_by_default = function (show) {')
                 .appendLine()
                 .append('                renderjson.options.show_to_level = show ? Number.MAX_VALUE : 0;')
                 .appendLine()
                 .append('                return renderjson;')
                 .appendLine()
                 .append('            };')
                 .appendLine()
                 .append('            renderjson.options = {};')
                 .appendLine()
                 .append('            renderjson.set_icons(''+'', ''-'');')
                 .appendLine()
                 .append('            renderjson.set_show_by_default(false);')
                 .appendLine()
                 .append('            renderjson.set_sort_objects(false);')
                 .appendLine()
                 .append('            renderjson.set_max_string_length("none");')
                 .appendLine()
                 .append('            renderjson.set_replacer(void 0);')
                 .appendLine()
                 .append('            renderjson.set_property_list(void 0);')
                 .appendLine()
                 .append('            renderjson.set_collapse_msg(function (len) { return len + " item" + (len == 1 ? "" : "s") })')
                 .appendLine()
                 .append('            return renderjson;')
                 .appendLine()
                 .append('        })();')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('        if (define) define({ renderjson: renderjson })')
                 .appendLine()
                 .append('        else (module || {}).exports = (window || {}).renderjson = renderjson;        ')
                 .appendLine()
                 .append('    </script>')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('    <style>')
                 .appendLine()
                 .append('        body {')
                 .appendLine()
                 .append('            background-color: #303030;            ')
                 .appendLine()
                 .append('        }')
                 .appendLine()
                 .append('        .renderjson a              { text-decoration: none; color: pink}')
                 .appendLine()
                 .append('        .renderjson .disclosure    { color: crimson;')
                 .appendLine()
                 .append('                                     font-size: 15px; }')
                 .appendLine()
                 .append('        .renderjson .syntax        { color: grey; }')
                 .appendLine()
                 .append('        .renderjson .string        { color: red; }')
                 .appendLine()
                 .append('        .renderjson .number        { color: cyan; }')
                 .appendLine()
                 .append('        .renderjson .boolean       { color: plum; }')
                 .appendLine()
                 .append('        .renderjson .key           { color: lightblue; }')
                 .appendLine()
                 .append('        .renderjson .keyword       { color: lightgoldenrodyellow; }')
                 .appendLine()
                 .append('        .renderjson .object.syntax { color: lightseagreen; }')
                 .appendLine()
                 .append('        .renderjson .array.syntax  { color: lightsalmon; }')
                 .appendLine()
                 .append('    </style>')
                 .appendLine()
                 .append('</head>')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('<body>')
                 .appendLine()
                 .append('    <div id="json"></div>')
                 .appendLine()
                 .append('    <script>')
                 .appendLine()
                 .append('        renderjson.set_show_to_level(4);')
                 .appendLine()
                 .append('        renderjson.set_icons(''+'', ''-'');')
                 .appendLine()
                 .append('        document.getElementById("json")')
                 .appendLine()
                 .append('            .appendChild(')
                 .appendLine()
                 .append('                renderjson(')
                 .appendLine()
                 .append('                            %s')
                 .appendLine()
                 .append('                          )')
                 .appendLine()
                 .append('            );')
                 .appendLine()
                 .append('    </script>')
                 .appendLine()
                 .append('</body>')
                 .appendLine()
                 .append('')
                 .appendLine()
                 .append('</html>')
                 .Replace('%s', AJSON).ToString;

    Result := Self;
  finally
    FreeAndNil(html);
  end;

end;

function TJSONUtils.getChildProperty(const AParent, AProperty, AJSON: string): IJSONUtils;
begin
  FJSON.Parse(BytesOf(AJSON), 0);

  FJSONArray := (FJSON.Get(AParent).JsonValue as TJSONArray);

  FJSONPair.Parse(BytesOf(FJSONArray.Items[0].ToJSON), 0);

  Result := getProperty(AProperty, FJSONPair.ToString);
end;

function TJSONUtils.getProperty(const AProperty, AJSON: string): IJSONUtils;
begin
  FJSON.Parse(BytesOf(UTF8Encode(AJSON)), 0);

  if Assigned(FJSON.Get(AProperty)) then
    FJSONProperty := FJSON.get(AProperty);
  Result := Self;
end;

class function TJSONUtils.new: IJSONUtils;
begin
  Result := Self.Create;
end;

procedure TJSONUtils.SetJSONProperty(const Value: TJSONPair);
begin
  FJSONProperty := Value;
end;

procedure TJSONUtils.show(AHandle: HWND);
var
  json: TStringList;
  path, fileHTML: string;
begin
  json := TStringList.Create;
  try
    path := ExtractFilePath(Application.ExeName);
    fileHTML := path + 'json.html';
    json.Text := FHTML;
    json.SaveToFile(fileHTML);

    ShellExecute(AHandle, 'open', PChar(fileHTML), nil, nil, SW_SHOW);
    Sleep(10000);

    DeleteFile(fileHTML);

  finally
    FreeAndNil(json);
  end;
end;

function TJSONUtils.getValue(): string;
begin
  if Assigned(FJSONProperty) then
    Result := FJSONProperty.JsonValue.ToString;
end;

function TJSONUtils.validateJSON(const AJSON: string): Boolean;
begin
  try
    Result := FJSON.Parse(BytesOf(AJSON), 0) >= 0;
  except
    on E: EJSONException do
      raise Exception.Create(E.Message);
  end;
end;

function TJSONUtils.getPair(): string;
begin
  if Assigned(FJSONProperty) then
    Result := FJSONProperty.ToJSON;
end;

end.

