"""Reviewed English component guidance and compiling examples."""
D = {'NgButton': {'title': 'Button',
              'use': 'Trigger an application action or submit a form.',
              'blazor': '<NgButton Primary OnClick="()=>count++">Clicked @count times</NgButton>\n'
                        '@code { private int count; }',
              'dart': 'int count = 0;\n'
                      'Widget build(BuildContext context) => NgButton(primary: true,\n'
                      "  onPressed: () => setState(() => count++), child: Text('Clicked $count times'));",
              'notes': 'Use OnClick/onPressed for application actions. In Blazor Type="submit" submits the '
                       'enclosing form; the default is button. In Flutter a null onPressed disables the '
                       'button. Disabled actions must also be guarded by your application when starting '
                       'asynchronous work. Primary uses the shared theme accent. Buttons support Tab and '
                       'Enter/Space; give icon-only content an accessible name.'},
 'NgTextBox': {'title': 'Single-line text',
               'use': 'Edit a string with a visible label and form validation.',
               'blazor': '<NgTextBox Label="Description" @bind-Value="text"/>\n'
                         '<p>@text</p>\n'
                         '@code { private string? text="Initial text"; }',
               'dart': "final text = TextEditingController(text: 'Initial text');\n"
                       '@override void dispose() { text.dispose(); super.dispose(); }\n'
                       "Widget build(BuildContext context) => NgTextBox(label: 'Description',\n"
                       "  controller: text, validator: (v) => v == null || v.trim().isEmpty ? 'Enter text' : "
                       'null);',
               'notes': 'Blazor uses InputBase<string?>: prefer @bind-Value, which supplies Value, '
                        'ValueChanged and ValueExpression. With manual binding, supply ValueExpression even '
                        'outside a form. Flutter initialValue is a starting value, not a controlled value: '
                        'use TextEditingController for programmatic changes, do not combine it with '
                        'initialValue, and dispose it in its owner. In a Flutter form validator returns null '
                        'for valid input or an error string. Keep drafts separate from saved records. '
                        'TextArea supports rows and multiline input; limits and required rules belong to the '
                        'field/form configuration. A validation error must block saving the entire form.'},
 'NgTextArea': {'title': 'Multiline text',
                'use': 'Edit a string with a visible label and form validation.',
                'blazor': '<NgTextArea Label="Description" @bind-Value="text" Rows="4" MaxLength="500"/>\n'
                          '<p>@text</p>\n'
                          '@code { private string? text="Initial text"; }',
                'dart': "final text = TextEditingController(text: 'Initial text');\n"
                        '@override void dispose() { text.dispose(); super.dispose(); }\n'
                        "Widget build(BuildContext context) => NgTextArea(label: 'Description',\n"
                        "  controller: text, validator: (v) => v == null || v.trim().isEmpty ? 'Enter text' "
                        ': null, rows: 4, maxLength: 500);',
                'notes': 'Blazor uses InputBase<string?>: prefer @bind-Value, which supplies Value, '
                         'ValueChanged and ValueExpression. With manual binding, supply ValueExpression even '
                         'outside a form. Flutter initialValue is a starting value, not a controlled value: '
                         'use TextEditingController for programmatic changes, do not combine it with '
                         'initialValue, and dispose it in its owner. In a Flutter form validator returns '
                         'null for valid input or an error string. Keep drafts separate from saved records. '
                         'TextArea supports rows and multiline input; limits and required rules belong to '
                         'the field/form configuration. A validation error must block saving the entire '
                         'form.'},
 'NgNumericTextBox': {'title': 'Numeric input',
                      'use': 'Edit a nullable number with range validation.',
                      'blazor': '<NgNumericTextBox Label="Quantity" Min="0" Max="100" Step="1" '
                                '@bind-Value="quantity"/>\n'
                                '@code { private decimal? quantity=5; }',
                      'dart': 'double? quantity = 5;\n'
                              "Widget build(BuildContext context) => NgNumericTextBox(label: 'Quantity',\n"
                              '  value: quantity, min: 0, max: 100, required: true,\n'
                              '  onChanged: (v) => setState(() => quantity = v));',
                      'notes': 'Min/Max are inclusive. Invalid text must not silently submit the last valid '
                               'number: submit through NgForm so the displayed draft is validated. Empty '
                               'optional input is null. Blazor uses its declared numeric type and InputBase '
                               'expression binding; Flutter uses double?. Keep storage precision and '
                               'business rounding in the application. Do not treat a numeric input as a '
                               'currency or timezone service.'},
 'NgCheckBox': {'title': 'Checkbox',
                'use': 'Edit a Boolean option.',
                'blazor': '<NgCheckBox Label="Notifications" @bind-Value="enabled"/>\n'
                          '@code { private bool enabled=true; }',
                'dart': 'bool enabled = true;\n'
                        "Widget build(BuildContext context) => NgCheckBox(label: 'Notifications',\n"
                        '  value: enabled, onChanged: (v) => setState(() => enabled = v));',
                'notes': 'The parent owns Value/value. Store ValueChanged/onChanged and pass the updated '
                         'value back; Flutter needs setState or your state manager. Disabled prevents '
                         'interaction. The label provides the accessible name. Keyboard focus and Space '
                         'toggle the control. These components represent true/false, not a tri-state value; '
                         'validate application requirements separately.'},
 'NgSwitch': {'title': 'Switch',
              'use': 'Edit a Boolean option.',
              'blazor': '<NgSwitch Label="Notifications" @bind-Value="enabled"/>\n'
                        '@code { private bool enabled=true; }',
              'dart': 'bool enabled = true;\n'
                      "Widget build(BuildContext context) => NgSwitch(label: 'Notifications',\n"
                      '  value: enabled, onChanged: (v) => setState(() => enabled = v));',
              'notes': 'The parent owns Value/value. Store ValueChanged/onChanged and pass the updated value '
                       'back; Flutter needs setState or your state manager. Disabled prevents interaction. '
                       'The label provides the accessible name. Keyboard focus and Space toggle the control. '
                       'These components represent true/false, not a tri-state value; validate application '
                       'requirements separately.'},
 'NgDropDownList': {'title': 'Dropdown list',
                    'use': 'Select one NgOption key from a local collection.',
                    'blazor': '<NgDropDownList Label="Team" Items="options" @bind-Value="team"/>\n'
                              '@code { private string team="design"; private NgOption[] '
                              'options=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)]; '
                              '}',
                    'dart': "String? team = 'design';\n"
                            "Widget build(BuildContext context) => NgDropDownList(label: 'Team', value: "
                            'team,\n'
                            "  items: const [NgOption('design','Design'), NgOption('dev','Engineering'),\n"
                            "    NgOption('locked','Unavailable', disabled: true)],\n"
                            '  onChanged: (v) => setState(() => team = v));',
                    'notes': 'NgOption contains value, label and disabled. Keys must be unique; selection '
                             'stores the key, not the displayed label. Disabled entries cannot be selected. '
                             'Replace the items collection when it changes and clear an obsolete selected '
                             'key in the parent. Blazor binding requires ValueExpression for InputBase-based '
                             'fields; use @bind-Value. Flutter initialValue initializes form state; reset '
                             'using the supported controller/key pattern. Use form validation for a required '
                             'choice. Large datasets and remote loading are outside this implementation.'},
 'NgRadioGroup': {'title': 'Radio group',
                  'use': 'Select one NgOption key from a local collection.',
                  'blazor': '<NgRadioGroup Label="Team" Items="options" @bind-Value="team"/>\n'
                            '@code { private string team="design"; private NgOption[] '
                            'options=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)]; '
                            '}',
                  'dart': "String? team = 'design';\n"
                          "Widget build(BuildContext context) => NgRadioGroup(label: 'Team', value: team,\n"
                          "  items: const [NgOption('design','Design'), NgOption('dev','Engineering'),\n"
                          "    NgOption('locked','Unavailable', disabled: true)],\n"
                          '  onChanged: (v) => setState(() => team = v));',
                  'notes': 'NgOption contains value, label and disabled. Keys must be unique; selection '
                           'stores the key, not the displayed label. Disabled entries cannot be selected. '
                           'Replace the items collection when it changes and clear an obsolete selected key '
                           'in the parent. Blazor binding requires ValueExpression for InputBase-based '
                           'fields; use @bind-Value. Flutter initialValue initializes form state; reset '
                           'using the supported controller/key pattern. Use form validation for a required '
                           'choice. Large datasets and remote loading are outside this implementation.'},
 'NgComboBox': {'title': 'Searchable selection',
                'use': 'Select one NgOption key from a local collection.',
                'blazor': '<NgComboBox Label="Team" Items="options" @bind-Value="team"/>\n'
                          '@code { private string? team="design"; private NgOption[] '
                          'options=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)]; '
                          '}',
                'dart': "String? team = 'design';\n"
                        "Widget build(BuildContext context) => NgComboBox(label: 'Team', value: team,\n"
                        "  items: const [NgOption('design','Design'), NgOption('dev','Engineering'),\n"
                        "    NgOption('locked','Unavailable', disabled: true)],\n"
                        '  onChanged: (v) => setState(() => team = v));',
                'notes': 'NgOption contains value, label and disabled. Keys must be unique; selection stores '
                         'the key, not the displayed label. Disabled entries cannot be selected. Replace the '
                         'items collection when it changes and clear an obsolete selected key in the parent. '
                         'Blazor binding requires ValueExpression for InputBase-based fields; use '
                         '@bind-Value. Flutter initialValue initializes form state; reset using the '
                         'supported controller/key pattern. ComboBox filters local options; use AutoComplete '
                         'when arbitrary text is allowed. There is no remote loading or virtualization.'},
 'NgAutoComplete': {'title': 'Text suggestions',
                    'use': 'Enter free text with suggestions from a local string list.',
                    'blazor': '<NgAutoComplete Label="City" Items="cities" @bind-Value="city"/>\n'
                              '@code { private string? city; private string[] '
                              'cities=["Kyiv","Lviv","Odesa"]; }',
                    'dart': "String city = '';\n"
                            "Widget build(BuildContext context) => NgAutoComplete(label: 'City',\n"
                            "  items: const ['Kyiv','Lviv','Odesa'], initialValue: city,\n"
                            '  onChanged: (v) => city = v);',
                    'notes': 'Text outside the suggestions is allowed. Use ComboBox when the value must be '
                             'an existing key. Flutter initialValue sets the starting text; recreate the '
                             'widget with a new Key for a complete external reset. Searching is local; the '
                             'application owns server requests, debounce and cancellation. Store callbacks '
                             'before submitting the draft.'},
 'NgMultiSelect': {'title': 'Multiple selection',
                   'use': 'Select several NgOption keys and remove selected items.',
                   'blazor': '<NgMultiSelect Label="Services" Items="options" MaxSelected="2" '
                             '@bind-Value="selected"/>\n'
                             '@code { private string[] selected=[]; private NgOption[] '
                             'options=[new("a","Delivery"),new("b","Assembly")]; }',
                   'dart': 'List<String> selected = [];\n'
                           "Widget build(BuildContext context) => NgMultiSelect(label: 'Services', value: "
                           'selected,\n'
                           "  items: const [NgOption('a','Delivery'),NgOption('b','Assembly')], maxSelected: "
                           '2,\n'
                           '  onChanged: (v) => setState(() => selected = v));',
                   'notes': 'Value is a collection of keys, not labels. The callback supplies a new list; '
                            'replace the parent collection. MaxSelected limits additions while removal '
                            'remains available. Flutter required demands at least one selection; in Blazor '
                            'define the rule in the form model. Search is local; large-list virtualization '
                            'and remote loading are not implemented.'},
 'NgDateInput': {'title': 'Date input',
                 'use': 'Select a calendar date or local wall-clock time without automatic timezone '
                        'conversion.',
                 'blazor': '<NgDateInput Label="Date" @bind-Value="value"/>\n'
                           '@code { private DateOnly? value=new(2026,10,20); }',
                 'dart': 'DateTime? value = DateTime(2026,10,20,9,30);\n'
                         'Widget build(BuildContext context) => NgDateInput(value: value,\n'
                         '  onChanged: (v) => setState(() => value = v));',
                 'notes': 'Input format: yyyy-MM-dd. Min/Max include boundary values. Invalid dates such as '
                          'April 31 and times such as 24:00 are rejected. DisabledDate returns true for '
                          'unavailable days. Blazor uses DateOnly, TimeOnly or DateTime; Flutter uses '
                          'DateTime or TimeOfDay. Normalize timezones at application boundaries. Empty '
                          'optional input is null. Validate required values through the form; Flutter also '
                          'exposes required. See [forms and dates](../forms-and-dates.md) for supported '
                          'calendar interactions and parsing limitations.'},
 'NgDatePicker': {'title': 'Date picker',
                  'use': 'Select a calendar date or local wall-clock time without automatic timezone '
                         'conversion.',
                  'blazor': '<NgDatePicker Label="Date" @bind-Value="value"/>\n'
                            '@code { private DateOnly? value=new(2026,10,20); }',
                  'dart': 'DateTime? value = DateTime(2026,10,20,9,30);\n'
                          'Widget build(BuildContext context) => NgDatePicker(value: value,\n'
                          '  onChanged: (v) => setState(() => value = v));',
                  'notes': 'Input format: yyyy-MM-dd. Min/Max include boundary values. Invalid dates such as '
                           'April 31 and times such as 24:00 are rejected. DisabledDate returns true for '
                           'unavailable days. Blazor uses DateOnly, TimeOnly or DateTime; Flutter uses '
                           'DateTime or TimeOfDay. Normalize timezones at application boundaries. Empty '
                           'optional input is null. Validate required values through the form; Flutter also '
                           'exposes required. See [forms and dates](../forms-and-dates.md) for supported '
                           'calendar interactions and parsing limitations.'},
 'NgCalendar': {'title': 'Calendar',
                'use': 'Select a calendar date or local wall-clock time without automatic timezone '
                       'conversion.',
                'blazor': '<NgCalendar @bind-Value="value"/>\n'
                          '@code { private DateOnly? value=new(2026,10,20); }',
                'dart': 'DateTime? value = DateTime(2026,10,20,9,30);\n'
                        'Widget build(BuildContext context) => NgCalendar(value: value,\n'
                        '  onChanged: (v) => setState(() => value = v));',
                'notes': 'Input format: calendar selection. Min/Max include boundary values. Invalid dates '
                         'such as April 31 and times such as 24:00 are rejected. DisabledDate returns true '
                         'for unavailable days. Blazor uses DateOnly, TimeOnly or DateTime; Flutter uses '
                         'DateTime or TimeOfDay. Normalize timezones at application boundaries. Empty '
                         'optional input is null. Validate required values through the form or application '
                         'rule; Calendar has no required parameter. See [forms and '
                         'dates](../forms-and-dates.md) for supported calendar interactions and parsing '
                         'limitations.'},
 'NgDateTimePicker': {'title': 'Date and time',
                      'use': 'Select a calendar date or local wall-clock time without automatic timezone '
                             'conversion.',
                      'blazor': '<NgDateTimePicker Label="Date" @bind-Value="value"/>\n'
                                '@code { private DateTime? value=new(2026,10,20,9,30,0); }',
                      'dart': 'DateTime? value = DateTime(2026,10,20,9,30);\n'
                              'Widget build(BuildContext context) => NgDateTimePicker(value: value,\n'
                              '  onChanged: (v) => setState(() => value = v));',
                      'notes': 'Input format: yyyy-MM-dd HH:mm. Min/Max include boundary values. Invalid '
                               'dates such as April 31 and times such as 24:00 are rejected. Blazor uses '
                               'DateOnly, TimeOnly or DateTime; Flutter uses DateTime or TimeOfDay. '
                               'Normalize timezones at application boundaries. Empty optional input is null. '
                               'Validate required values through the form; Flutter also exposes required. '
                               'See [forms and dates](../forms-and-dates.md) for supported calendar '
                               'interactions and parsing limitations.'},
 'NgTimePicker': {'title': 'Time picker',
                  'use': 'Select a calendar date or local wall-clock time without automatic timezone '
                         'conversion.',
                  'blazor': '<NgTimePicker Label="Date" @bind-Value="value"/>\n'
                            '@code { private TimeOnly? value=new(9,30); }',
                  'dart': 'TimeOfDay? value = const TimeOfDay(hour: 9, minute: 30);\n'
                          'Widget build(BuildContext context) => NgTimePicker(value: value,\n'
                          '  onChanged: (v) => setState(() => value = v));',
                  'notes': 'Input format: HH:mm. Min/Max include boundary values. Invalid dates such as '
                           'April 31 and times such as 24:00 are rejected. Blazor uses DateOnly, TimeOnly or '
                           'DateTime; Flutter uses DateTime or TimeOfDay. Normalize timezones at application '
                           'boundaries. Empty optional input is null. Validate required values through the '
                           'form; Flutter also exposes required. See [forms and '
                           'dates](../forms-and-dates.md) for supported calendar interactions and parsing '
                           'limitations.'},
 'NgDateRangePicker': {'title': 'Date range',
                       'use': 'Edit a linked start and end date.',
                       'blazor': '<NgDateRangePicker Label="Period" @bind-Value="range"/>\n'
                                 '@code { private NgDateRange? range=new(new(2026,10,20),new(2026,10,23)); }',
                       'dart': 'NgDateRange? range = NgDateRange(DateTime(2026,10,20), '
                               'DateTime(2026,10,23));\n'
                               "Widget build(BuildContext context) => NgDateRangePicker(label: 'Period', "
                               'value: range,\n'
                               '  required: true, onChanged: (v) => setState(() => range = v));',
                       'notes': 'NgDateRange contains nullable Start/End (Blazor DateOnly, Flutter '
                                'DateTime). An end before the start is invalid. Min/Max constrain both '
                                'endpoints. Callbacks replace the whole range. A partially filled draft may '
                                'exist; the form determines whether it is valid for submission. Do not save '
                                'the last valid model while an invalid draft is visible: submit through '
                                'NgForm. This is a calendar-date range, not a timezone-aware interval.'},
 'NgForm': {'title': 'Form validation',
            'use': 'Validate fields and run a save handler only after successful validation.',
            'blazor': '<NgForm Model="model" OnValidSubmit="Save">\n'
                      '    <NgTextBox Label="Name" @bind-Value="model.Name"/>\n'
                      '    <NgButton Type="submit" Primary>Save</NgButton>\n'
                      '</NgForm>\n'
                      '<p>@status</p>\n'
                      '@code {\n'
                      ' private Draft model=new(); private string? status;\n'
                      ' private void Save()=>status=$"Saved: {model.Name}";\n'
                      ' public class Draft { [System.ComponentModel.DataAnnotations.Required] public string? '
                      'Name {get;set;} }\n'
                      '}',
            'dart': "String name = '';\n"
                    "Widget build(BuildContext context) => NgForm(submitLabel: 'Save',\n"
                    "  onValidSubmit: () => debugPrint('Saved: $name'),\n"
                    "  child: NgTextBox(label: 'Name', onChanged: (v) => name = v,\n"
                    "    validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null));",
            'notes': 'Blazor Model uses DataAnnotations; OnValidSubmit receives a valid form and '
                     'OnInvalidSubmit reports a failed submission. Keep one model instance while editing. '
                     'Flutter uses a GlobalKey<FormState>, field validators/required rules and the supplied '
                     'submit handler. Return null for valid field values, otherwise an error message. '
                     'Network failures belong to the application save flow, not numeric/date parsing. Avoid '
                     'nested forms. Maintain a separate saved record so Cancel can discard the draft.'},
 'NgTabs': {'title': 'Tabs',
            'use': 'Switch between related content panels.',
            'blazor': '<NgTabs Items="tabs" @bind-SelectedIndex="index"/>\n'
                      '@code { private int index; private NgTab[] '
                      'tabs=[new("Overview",b=>b.AddContent(0,"Summary")),new("Details",b=>b.AddContent(0,"Details"))]; '
                      '}',
            'dart': 'int index = 0;\n'
                    'Widget build(BuildContext context) => NgTabs(selectedIndex: index,\n'
                    "  items: const [NgTab('Overview',Text('Summary')),NgTab('Details',Text('Details'))],\n"
                    '  onChanged: (v) => setState(() => index = v));',
            'notes': 'NgTab contains label and content; disabled tabs cannot be activated. SelectedIndex is '
                     'zero-based and controlled by the parent. Store selection callbacks. Blazor connects '
                     'tab IDs, aria-controls and panel labels, and installs its keyboard behavior through '
                     'the packaged JS module; interactive rendering and static assets are required. Flutter '
                     'uses its platform focus behavior. Keep business state in the parent rather than '
                     'depending on the lifetime of a panel widget.'},
 'NgDialog': {'title': 'Modal dialog',
              'use': 'Ask for a focused decision in a modal surface.',
              'blazor': '<NgButton OnClick="()=>open=true">Open</NgButton>\n'
                        '<NgDialog Title="Confirmation" '
                        '@bind-Open="open"><ChildContent>Continue?</ChildContent><Actions><NgButton '
                        'OnClick="()=>open=false">Close</NgButton></Actions></NgDialog>\n'
                        '@code { private bool open; }',
              'dart': "Widget build(BuildContext context) => NgButton(child: const Text('Open'),\n"
                      "  onPressed: () => NgDialog.show<void>(context, title: 'Confirmation',\n"
                      "    child: const Text('Continue?'), actions: [TextButton(\n"
                      "      onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))]));",
              'notes': 'Blazor Open/OpenChanged control visibility. Flutter uses the dialog helper shown in '
                       'the example. Supply a meaningful title, content and explicit actions. Escape '
                       'dismisses the dialog; opening should move focus into it and closing restore focus to '
                       'the trigger. Save and Cancel have different application semantics: cancelling must '
                       'not persist the draft. Nested modal workflows and a full screen-reader certification '
                       'are outside this release.'},
 'NgTooltip': {'title': 'Tooltip',
               'use': 'Explain a control with a short nonessential hint.',
               'blazor': '<NgTooltip Text="Create a copy"><NgButton>Copy</NgButton></NgTooltip>',
               'dart': "Widget build(BuildContext context) => NgTooltip(text: 'Create a copy',\n"
                       "  child: NgButton(onPressed: () {}, child: const Text('Copy')));",
               'notes': 'Supply Text/text and the child control. Tooltips are supplementary: the child still '
                        'needs an accessible name and essential instructions must remain visible. Use '
                        'pointer hover or keyboard focus to reveal the hint. Do not place form fields, '
                        'actions or long documents inside a tooltip.'},
 'NgNotification': {'title': 'Notification',
                    'use': 'Show an inline application status message.',
                    'blazor': '<NgNotification @bind-Visible="visible" '
                              'Tone="success">Saved</NgNotification>\n'
                              '@code { private bool visible=true; }',
                    'dart': 'bool visible = true;\n'
                            'Widget build(BuildContext context) => visible ? NgNotification(message: '
                            "'Saved',\n"
                            '  onDismiss: () => setState(() => visible = false)) : const SizedBox.shrink();',
                    'notes': 'Message is plain text. Tone controls semantic color; do not communicate '
                             'meaning through color alone. Dismissal invokes the supplied callback; update '
                             'Visible/visible in the parent. This is not a timed global toast queue. Keep '
                             'critical validation errors next to their fields and avoid placing confidential '
                             'exception details in user-facing text.'},
 'NgPager': {'title': 'Pagination',
             'use': 'Navigate a known number of records.',
             'blazor': '<NgPager Total="items.Length" @bind-Page="page" @bind-PageSize="size"/>\n'
                       '@foreach(var item in items.Skip((page-1)*size).Take(size)){<p>@item</p>}\n'
                       '@code { private int page=1,size=5; private string[] '
                       'items=Enumerable.Range(1,18).Select(i=>$"Row {i}").ToArray(); }',
             'dart': 'int page = 1, size = 5;\n'
                     'Widget build(BuildContext context) => NgPager(total: 18, page: page, pageSize: size,\n'
                     '  onPageChanged: (v) => setState(() => page = v),\n'
                     '  onPageSizeChanged: (v) => setState(() { size = v; page = 1; }));',
             'notes': 'Page is one-based; PageSize is positive, Total is the count before paging. Store '
                      'PageChanged and PageSizeChanged, and reset/clamp the page when the filter or size '
                      'changes. The pager does not fetch or slice data: the example performs Skip/Take or '
                      'equivalent application slicing. Disable impossible navigation at the first/last page. '
                      'Server paging must provide a consistent total and handle stale asynchronous '
                      'responses.'},
 'NgBreadcrumb': {'title': 'Breadcrumb',
                  'use': 'Navigate the ancestors of the current location.',
                  'blazor': '<NgBreadcrumb Items="items" OnNavigate="id=>selected=id"/>\n'
                            '<p>@selected</p>\n'
                            '@code { private string? selected; private NgBreadcrumbItem[] '
                            'items=[new("all","Projects"),new("design","Design")]; }',
                  'dart': 'String? selected;\n'
                          'Widget build(BuildContext context) => NgBreadcrumb(\n'
                          '  items: const '
                          "[NgBreadcrumbItem('all','Projects'),NgBreadcrumbItem('design','Design')],\n"
                          '  onNavigate: (id) => setState(() => selected = id));',
                  'notes': 'Each NgBreadcrumbItem has an ID and visible label. The final item represents the '
                           'current page. OnNavigate/onNavigate reports the ancestor ID; route navigation '
                           'belongs to the host application. Keep IDs stable and do not use labels as '
                           'database keys.'},
 'NgDataGrid': {'title': 'Data grid',
                'use': 'Display, sort, filter, select and page local records.',
                'blazor': '<NgDataGrid TItem="Product" Items="rows" Columns="columns" RowId="r=>r.Id" '
                          '@bind-SelectedIds="selected"/>\n'
                          '@code { public record Product(string Id,string Name,int Count); private Product[] '
                          'rows=[new("a","Desk",12),new("b","Chair",120)]; private HashSet<string> '
                          'selected=[]; private NgDataColumn<Product>[] '
                          'columns=[new("name","Name",r=>r.Name),new("count","Quantity",r=>r.Count)]; }',
                'dart': "final rows = [(id: 'a', name: 'Desk', count: 12), (id: 'b', name: 'Chair', count: "
                        '120)];\n'
                        'Set<String> selected = {};\n'
                        'Widget build(BuildContext context) => NgDataGrid<({String id, String name, int '
                        'count})>(\n'
                        '  items: rows, rowId: (r) => r.id, selectedIds: selected,\n'
                        '  onSelectionChanged: (v) => setState(() => selected = v),\n'
                        "  columns: [NgDataColumn('name','Name',(r) => r.name),\n"
                        "    NgDataColumn('count','Quantity',(r) => r.count)]);",
                'notes': 'NgDataColumn<T> supplies a stable key, title and Value/value accessor. Return '
                         'typed values for sorting; Format/format changes display only. Template/cellBuilder '
                         'customizes a cell. RowId must return a unique stable ID. Save selection callbacks '
                         'and replace Items/items after edits so the grid recalculates. Toolbar and row '
                         'actions allow the application to own editing and persistence. This local grid does '
                         'not implement server data binding, virtualization, column grouping or Excel '
                         'export; see [data workspace](../data-workspace.md).'},
 'NgTreeView': {'title': 'Tree view',
                'use': 'Browse and select hierarchical records.',
                'blazor': '<NgTreeView TItem="string" Items="nodes" Text="s=>s" @bind-ExpandedIds="expanded" '
                          '@bind-SelectedId="selected"/>\n'
                          '@code { private string? selected; private HashSet<string> expanded=["root"]; '
                          'private NgTreeNode<string>[] '
                          'nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; }',
                'dart': "Set<String> expanded = {'root'}; String? selected;\n"
                        'Widget build(BuildContext context) => NgTreeView<String>(\n'
                        "  items: const [NgTreeNode('root','Projects',children: "
                        "[NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],\n"
                        '  text: (s) => s,\n'
                        '  expandedIds: expanded, selectedId: selected,\n'
                        '  onExpandedChanged: (v) => setState(() => expanded = v),\n'
                        '  onSelected: (v) => setState(() => selected = v));',
                'notes': 'NgTreeNode<T> contains a stable unique ID, item, children and disabled flag. The '
                         'graph must be acyclic. ExpandedIds and SelectedId are controlled: save callbacks '
                         'and pass updated collections back. Replacing the tree should also remove obsolete '
                         'IDs from parent selection/expansion. Disabled nodes cannot be selected. Lazy '
                         'server loading, drag/drop and virtualization are not implemented.'},
 'NgTreeList': {'title': 'Tree list',
                'use': 'Combine hierarchical rows with typed columns.',
                'blazor': '<NgTreeList TItem="string" Items="nodes" Columns="columns" '
                          '@bind-ExpandedIds="expanded" @bind-SelectedId="selected"/>\n'
                          '@code { private string? selected; private HashSet<string> expanded=["root"]; '
                          'private NgTreeNode<string>[] '
                          'nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; '
                          'private NgDataColumn<string>[] columns=[new("name","Name",s=>s)]; }',
                'dart': "Set<String> expanded = {'root'}; String? selected;\n"
                        'Widget build(BuildContext context) => NgTreeList<String>(\n'
                        "  items: const [NgTreeNode('root','Projects',children: "
                        "[NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],\n"
                        "  columns: [NgDataColumn('name','Name',(s) => s)],\n"
                        '  expandedIds: expanded, selectedId: selected,\n'
                        '  onExpandedChanged: (v) => setState(() => expanded = v),\n'
                        '  onSelected: (v) => setState(() => selected = v));',
                'notes': 'Use NgTreeNode<T> for hierarchy and NgDataColumn<T> for cells. IDs must be unique '
                         'across the whole tree. Persist expanded/selected IDs through callbacks; replace '
                         'collections after data changes. Column accessors return underlying values, while '
                         'format/cell templates define presentation. Application code owns edits and '
                         'persistence. See [data workspace](../data-workspace.md) for sorting/filtering '
                         'scope and omitted server/virtualization features.'},
 'NgChart': {'title': 'Chart',
             'use': 'Visualize local series as column, bar, line, area, pie or donut charts.',
             'blazor': '<NgChart Title="Sales" Kind="NgChartKind.Line" Categories="categories" '
                       'Series="series" OnPointSelected="p=>selected=p.Label"/>\n'
                       '<p>@selected</p>\n'
                       '@code { private string? selected; private string[] categories=["Mon","Tue","Wed"]; '
                       'private NgChartSeries[] series=[new("Orders",[10,null,25])]; }',
             'dart': 'String? selected;\n'
                     "Widget build(BuildContext context) => NgChart(title: 'Sales', kind: NgChartKind.line,\n"
                     "  categories: const ['Mon','Tue','Wed'], series: const "
                     "[NgChartSeries('Orders',[10,null,25])],\n"
                     '  onPointSelected: (p) => setState(() => selected = p.label));',
             'notes': 'Categories define the shared domain; every series must have the same number of '
                      'nullable numeric values. Null breaks a line instead of becoming zero. Point selection '
                      'returns NgChartSelection with zero-based series/point indices, their names, the '
                      'number and a ready-to-use label. The application chooses what to do with a point. '
                      'Keep units explicit. See [analytics and scheduling](../analytics-and-schedule.md) for '
                      'mode-specific constraints; advanced axes, export, remote aggregation and broad '
                      'chart-type parity are not implemented.'},
 'NgLinearGauge': {'title': 'Linear gauge',
                   'use': 'Display a value within a numeric range.',
                   'blazor': '<NgLinearGauge Label="Load" Value="72" Min="0" Max="100" Unit="%"/>',
                   'dart': "Widget build(BuildContext context) => const NgLinearGauge(label: 'Load',\n"
                           "  value: 72, min: 0, max: 100, unit: '%');",
                   'notes': 'Min must be less than Max and values must be finite. The gauge projects the '
                            'configured value into the range; keep the original business value in the '
                            'parent. Label and Unit explain the number without relying on color. This is a '
                            'read-only display, not an input or a multi-scale gauge. Use the shared theme '
                            'for light/dark contrast.'},
 'NgArcGauge': {'title': 'Arc gauge',
                'use': 'Display a value within a numeric range.',
                'blazor': '<NgArcGauge Label="Load" Value="72" Min="0" Max="100" Unit="%"/>',
                'dart': "Widget build(BuildContext context) => const NgArcGauge(label: 'Load',\n"
                        "  value: 72, min: 0, max: 100, unit: '%');",
                'notes': 'Min must be less than Max and values must be finite. The gauge projects the '
                         'configured value into the range; keep the original business value in the parent. '
                         'Label and Unit explain the number without relying on color. This is a read-only '
                         'display, not an input or a multi-scale gauge. Use the shared theme for light/dark '
                         'contrast.'},
 'NgScheduler': {'title': 'Weekly scheduler',
                 'use': 'Show a week of application events and request create/edit actions.',
                 'blazor': '<NgScheduler @bind-Date="week" Items="events" '
                           'OnCreate="day=>message=day.ToShortDateString()" '
                           'OnEdit="item=>message=item.Title"/>\n'
                           '<p>@message</p>\n'
                           '@code { private DateTime week=new(2026,10,19); private string? message; private '
                           'NgScheduleEvent[] '
                           'events=[new("a","Meeting",new(2026,10,19,10,0,0),new(2026,10,19,11,0,0))]; }',
                 'dart': 'DateTime week = DateTime(2026,10,19);\n'
                         'Widget build(BuildContext context) => NgScheduler(date: week,\n'
                         '  items: '
                         "[NgScheduleEvent('a','Meeting',DateTime(2026,10,19,10),DateTime(2026,10,19,11))],\n"
                         '  onDateChanged: (v) => setState(() => week = v),\n'
                         "  onCreate: (day) => debugPrint('Add $day'),\n"
                         '  onEdit: (item) => debugPrint(item.title));',
                 'notes': 'NgScheduleEvent requires a unique ID, nonempty title and End > Start. Date '
                          'chooses the displayed week. Store DateChanged/onDateChanged; OnCreate/onCreate '
                          'identifies a day, while OnEdit/onEdit identifies an event. The application opens '
                          'its editor and replaces the event collection after saving. Times are local '
                          'wall-clock values; timezone conversion belongs to the host. Recurrence, '
                          'drag/resize, resources and multiple calendar views are not implemented.'},
 'NgSpreadsheet': {'title': 'Spreadsheet',
                   'use': 'Edit a small local worksheet with formulas and undo/redo.',
                   'blazor': '<NgSpreadsheet @bind-Value="sheet"/>\n'
                             '@code { private NgSheet sheet=new(8,5,new '
                             'Dictionary<string,string>{{"A1","10"},{"B1","20"},{"C1","=SUM(A1:B1)"}}); }',
                   'dart': 'NgSheet sheet = NgSheet(rows: 8, columns: 5, cells: '
                           "{'A1':'10','B1':'20','C1':'=SUM(A1:B1)'});\n"
                           'Widget build(BuildContext context) => NgSpreadsheet(value: sheet,\n'
                           '  onChanged: (v) => setState(() => sheet = v));',
                   'notes': 'Select a cell, edit Cell value or formula, then press Apply cell or Enter. '
                            'Arrow keys move selection. NgSheet is immutable; save the entire new sheet from '
                            'the callback. Undo/Redo keeps up to 50 operations; an independent parent Value '
                            'replacement clears local history. ReadOnly disables edits. Paste cells accepts '
                            'rectangular TSV from the selected address, preserves formula text literally and '
                            'rejects an out-of-bounds paste as a whole. Limits: 1–100 rows, 1–26 columns, '
                            '1,000 characters per cell. See [models and formulas](models.md) for '
                            'operators/functions/errors. One sheet only: no XLSX/CSV files, formatting, '
                            'merges, relative formula adjustment or multi-sheet workbook.'},
 'NgPivotGrid': {'title': 'Pivot grid',
                 'use': 'Aggregate records by row and column dimensions.',
                 'blazor': '<NgPivotGrid Items="records" RowField="Team" ColumnField="Quarter" '
                           'Aggregate="NgAggregate.Average" OnCellSelected="p=>count=p.Records.Count"/>\n'
                           '<p>Source records: @count</p>\n'
                           '@code { private int count; private NgPivotRecord[] records=[new("a",new '
                           'Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},100),new("b",new '
                           'Dictionary<string,string>{{"Team","Design"},{"Quarter","Q1"}},200)]; }',
                 'dart': 'int count = 0;\n'
                         "Widget build(BuildContext context) => NgPivotGrid(rowField: 'Team', columnField: "
                         "'Quarter',\n"
                         '  aggregate: NgAggregate.average, items: [\n'
                         "    NgPivotRecord('a', {'Team':'Design','Quarter':'Q1'},100),\n"
                         "    NgPivotRecord('b', {'Team':'Design','Quarter':'Q1'},200)],\n"
                         '  onCellSelected: (p) => setState(() => count = p.records.length));',
                 'notes': 'NgPivotRecord contains a unique ID, string dimensions and one nullable numeric '
                          'value. Dimensions sort by string keys; a missing key appears as (blank). '
                          'Sum/Average/Min/Max use numeric values; Count includes source records with null '
                          'values. Totals are recalculated from source records, so an average is not an '
                          'average of averages. Cell/total callbacks return the original records; null '
                          'Row/Column denotes a total, while an empty string denotes a blank dimension. '
                          'Filter Items/items before passing them in. Multiple grouping levels, measures, '
                          'OLAP and a drag/drop configurator are not implemented.'},
 'NgEditor': {'title': 'Structured document editor',
              'use': 'Edit a small document as typed blocks with a separate preview.',
              'blazor': '<NgEditor Label="Project description" @bind-Value="document"/>\n'
                        '<NgButton OnClick="Save">Save JSON</NgButton>\n'
                        '<pre>@saved</pre>\n'
                        '@code {\n'
                        '    private NgDocument document = new([\n'
                        '        new("Project plan", NgBlockKind.Heading1),\n'
                        '        new("Agree on requirements", NgBlockKind.Bullet),\n'
                        '        new("Review the result", NgBlockKind.Bullet, Bold: true)\n'
                        '    ]);\n'
                        '    private string saved = "";\n'
                        '    private void Save() => saved = document.ToJson();\n'
                        '}',
              'dart': 'NgDocument document = NgDocument(blocks: const [\n'
                      "  NgDocumentBlock(text: 'Project plan', kind: NgBlockKind.heading1),\n"
                      "  NgDocumentBlock(text: 'Agree on requirements', kind: NgBlockKind.bullet),\n"
                      "  NgDocumentBlock(text: 'Review the result', kind: NgBlockKind.bullet, bold: true),\n"
                      ']);\n'
                      "String saved = '';\n"
                      'Widget build(BuildContext context) => Column(children: [\n'
                      "  NgEditor(label: 'Project description', value: document,\n"
                      '    onChanged: (v) => setState(() => document = v)),\n'
                      '  NgButton(onPressed: () => setState(() => saved = document.toJson()),\n'
                      "    child: const Text('Save JSON')),\n"
                      '  Text(saved),\n'
                      ']);',
              'notes': '### Editing\n'
                       'Select a block, change Block text and press Apply text. Until applied, the local '
                       'draft is not included in callbacks, preview or export. Block type supports '
                       'paragraphs, level 1/2 headings, bullet/numbered items and quotes. Bold, Italic, '
                       'Underline and Alignment apply to the entire block, not a selected text range.\n'
                       '\n'
                       'Changing selection/type/alignment/formatting, Add block and Move automatically '
                       'applies the draft; one action creates one history entry. Add inserts a paragraph '
                       'after the current block. Move preserves selection. Delete discards the selected '
                       'draft; deleting the final block leaves one empty paragraph. Undo/Redo stores the '
                       'last 50 applied operations and discards an unapplied draft.\n'
                       '\n'
                       '### State and storage\n'
                       'Value is an immutable NgDocument. Save the new instance from ValueChanged/onChanged '
                       'and pass it back. An independent replacement (import or another file) resets history '
                       'and draft; do not manufacture an equivalent new instance on every render. ReadOnly '
                       'preserves selection/preview but does not auto-save a pending draft. NgEditor is not '
                       'an InputBase/FormField: the host validates document business rules.\n'
                       '\n'
                       'ToJson/toJson produces the shared version-1 format. Restore with '
                       'NgDocument.FromJson/fromJson, catch ArgumentException/ArgumentError and preserve the '
                       'current document on failure. ToHtml/toHtml exports applied blocks only, escapes '
                       'text, groups adjacent list items and converts newlines to br. It returns a fragment '
                       'without theme/container. Store JSON as the editable source; HTML import is not '
                       'supported. The component does not upload or write files. The Editor gallery '
                       'demonstrates Save/Restore.\n'
                       '\n'
                       '### Keyboard and limits\n'
                       'Tab navigates controls; Enter/Space activates buttons. The textarea uses ordinary '
                       'multiline input. Document Undo/Redo buttons are separate from operating-system '
                       'text-input undo; there are no custom Ctrl+Z/Ctrl+Y shortcuts.\n'
                       '\n'
                       'Limits: 1–100 blocks, 10,000 UTF-16 units per block, 100,000 total, 1,000,000 units '
                       'of input JSON. The model checks each operation. No nested lists, links, images, '
                       'tables, font picker, selection formatting, HTML/Word import, PDF/print, '
                       'collaboration, AI or virtualization. Native mobile and full screen-reader '
                       'verification remain separate.'},
 'NgDiagram': {'title': 'Interactive diagram',
               'use': 'Display and edit a graph of nodes and directed or undirected connections.',
               'blazor': '<NgDiagram Label="Process" @bind-Value="graph"\n'
                         '    @bind-SelectedNodeId="selectedNode" @bind-SelectedEdgeId="selectedEdge"/>\n'
                         '<p>Node: @selectedNode · Connection: @selectedEdge</p>\n'
                         '@code {\n'
                         '    private string? selectedNode, selectedEdge;\n'
                         '    private NgDiagramModel graph = new([\n'
                         '        new("start", "Start", 40, 100, Shape: NgDiagramShape.Ellipse),\n'
                         '        new("work", "Processing", 360, 100)\n'
                         '    ], [new("next", "start", "work", "Continue")]);\n'
                         '}',
               'dart': 'NgDiagramModel graph = NgDiagramModel(nodes: const [\n'
                       "  NgDiagramNode('start', 'Start', 40, 100, shape: NgDiagramShape.ellipse),\n"
                       "  NgDiagramNode('work', 'Processing', 360, 100),\n"
                       "], edges: const [NgDiagramEdge('next', 'start', 'work', text: 'Continue')]);\n"
                       'String? selectedNode, selectedEdge;\n'
                       "Widget build(BuildContext context) => NgDiagram(label: 'Process', value: graph,\n"
                       '  onChanged: (v) => setState(() => graph = v),\n'
                       '  selectedNodeId: selectedNode, selectedEdgeId: selectedEdge,\n'
                       '  onSelectedNodeIdChanged: (v) => setState(() => selectedNode = v),\n'
                       '  onSelectedEdgeIdChanged: (v) => setState(() => selectedEdge = v));',
               'notes': '### Selection and movement\n'
                        'Click a node or connection to select it. The other selection type is first cleared '
                        'through its callback with null. Store both selected IDs. Unknown IDs are not '
                        'highlighted; remove stale selection when deleting data. Dragging previews a new '
                        'position, and only pointer release commits coordinates and invokes '
                        'ValueChanged/onChanged. Escape cancels drag. Tab focuses nodes; Enter/Space '
                        'selects; arrows move 10 units, Shift+arrow moves 1. Movement stays inside the '
                        'canvas. Flutter exposes keyboard-selectable Connections; Blazor SVG connections are '
                        'focusable.\n'
                        '\n'
                        '### Zoom and viewport\n'
                        'Zoom changes by 25 percentage points, within 25–200%. Fit width fits the entire '
                        'canvas width; 100% resets zoom. The viewport is 420 logical/CSS pixels tall, with '
                        'internal scrolling. Zoom does not alter model coordinates or JSON. Fit diagram fits '
                        'node bounds in both axes with 24 px padding and centers by scrolling; it preserves '
                        'selection and works in ReadOnly. Empty graphs disable it. Minimum zoom can still '
                        'require scrolling for large graphs; canvas boundaries constrain centering and long '
                        'connection labels may extend beyond bounds. Fitting is explicit, not automatic '
                        'layout.\n'
                        '\n'
                        'NgDiagramModel.FitView/fitView(viewportWidth,viewportHeight) returns NgDiagramView '
                        '(Zoom/ScrollX/ScrollY or lowerCamelCase). Sizes must be finite and positive. An '
                        'empty graph returns 100% and zero scroll.\n'
                        '\n'
                        '### Model and persistence\n'
                        'Value is immutable. Store the new graph from callbacks; an independent replacement '
                        'cancels active drag. ReadOnly disables movement but retains selection, zoom and '
                        'scrolling. The application owns create/edit/delete actions and their permissions. '
                        'The gallery shows a properties panel, connections, 20-change history and import; '
                        'NgDiagram itself has no undo history.\n'
                        '\n'
                        'UpsertNode/UpsertEdge add or replace by ID. RemoveNode also removes incident edges; '
                        'RemoveEdge keeps nodes. Move(id,x,y) clamps coordinates to the canvas and returns a '
                        'new model. For example: graph = graph.Move("start",80,120), or graph = '
                        "graph.move('start',80,120). ToJson/toJson and FromJson/fromJson use the shared "
                        'version-1 Nextgen schema, not Telerik JSON. Catch invalid imports and retain the '
                        'previous graph. No automatic file storage or upload.\n'
                        '\n'
                        '### Geometry and limits\n'
                        'Shapes: rectangle, ellipse, diamond (PascalCase enum names in C#). Nodes store ID, '
                        'text, top-left X/Y and width/height (default 160×80). Labels are visually shortened '
                        'but available in tooltips/accessibility/properties. Connections run straight '
                        'between shape boundaries along the centers; directed connections have an end arrow. '
                        'On-canvas connection labels shorten to 24 characters.\n'
                        '\n'
                        'Canvas dimensions: 200–5000 (default 1000×600); up to 100 nodes and 200 edges. '
                        'Nodes: 60–400 × 40–240, fully inside the canvas. IDs: 1–64 ASCII '
                        'letters/digits/_/-, unique separately for nodes and edges. Node text is nonempty '
                        'and at most 100 UTF-16 units; edge text 0–100. Coordinates are finite. Edges '
                        'require two different existing nodes. Cycles and parallel edges are allowed; '
                        'workflow rules belong to the application. Overlaps are not resolved automatically; '
                        'coincident centers yield a zero-length line.\n'
                        '\n'
                        'No automatic layout, obstacle routing, connector drawing, pointer resizing, groups, '
                        'multiple selection, image/templates, export, minimap, pinch zoom or collaboration. '
                        'Blazor loads diagram.js automatically from static web assets and requires '
                        'interactive rendering; if drag fails, check the module and ValueChanged handling. '
                        'Native/mobile and screen-reader audits remain separate.'},
 'NgPdfViewer': {'title': 'PDF viewer',
                 'use': 'Open, navigate, search and copy text from PDF documents.',
                 'blazor': '<NgPdfViewer Label="Guide" Source="samples/nextgen-guide.pdf" Height="720" '
                           'Dark="false"/>\n'
                           '<p>PDF must be hosted by the application at this address.</p>',
                 'dart': 'Widget build(BuildContext context) => const NgPdfViewer(\n'
                         "  label: 'Guide', source: 'samples/nextgen-guide.pdf', height: 720);",
                 'notes': '### Hosting and sources\n'
                          'Source is a relative or HTTP(S) URL resolved from the app base URI. Host the file '
                          'yourself in wwwroot/samples (Blazor) or web/samples (Flutter). Empty source opens '
                          'the viewer with Open PDF. Browser requests send same-origin cookies only to their '
                          'origin; remote servers must allow CORS. Open PDF reads a local file without '
                          'upload. PDF.js, worker, CMaps and fonts are packaged locally; no CDN or '
                          'additional script tag is needed.\n'
                          '\n'
                          'Blazor serves _content/NextgenComponents.Blazor/pdf-viewer/. With UseStaticFiles '
                          'map .mjs to text/javascript and .bcmap/.pfb to application/octet-stream (see '
                          'gallery Program.cs). The iframe works under SSR; parent parameter changes require '
                          'interactivity. Flutter package assets supply the viewer. CSP must permit the '
                          'required local frame/scripts/styles/workers/fonts and source connections, '
                          'including blob workers/fonts where used; configure it in the host.\n'
                          '\n'
                          '### Navigation, search and state\n'
                          'Previous/Next and Page use one-based page numbers. Zoom is 10–300%, with 25-point '
                          'button increments. Fit width/page recomputes on viewport resize. Enlarged pages '
                          'scroll internally. Height is 400–1600, default 640; the toolbar wraps on narrow '
                          'widths and leaves at least 100 px for the page.\n'
                          '\n'
                          'Find searches a case-insensitive substring across every page, normalizing '
                          'whitespace and matching across text items/lines. Results list page numbers; '
                          'selecting one opens that page and Page text. Clear removes '
                          'query/results/highlights. Page text supports ordinary selection/copy. Text can '
                          'also be selected over the rendered page; Ctrl/Cmd+C uses the browser clipboard. '
                          'Current-page matches are highlighted (up to 1,000 non-overlapping matches), '
                          'surviving zoom/navigation/fit. Find applies a changed query; Clear, an empty Find '
                          'and document changes reset it. Redrawing clears ordinary selection. Highlight '
                          'geometry depends on PDF fonts/text; CSS Custom Highlight API is used in Chrome, '
                          'with page search and selection as fallback. No OCR: scanned PDFs without text '
                          'cannot be searched. Hyphenation, ligatures and source text order may affect '
                          'matching.\n'
                          '\n'
                          'Download saves the original bytes, including locally opened files. Filenames from '
                          'URLs/files are stripped of control characters/path separators. The viewer does '
                          'not edit PDF. Page/zoom/search/local-file state belongs to the iframe. Source or '
                          'theme changes recreate it and reset state; reopen local files after a theme '
                          'change. Identical parent rebuilds preserve it. Page/load callbacks and controlled '
                          'page binding are not implemented.\n'
                          '\n'
                          '### Limits and failures\n'
                          'At most 20 MiB and 200 pages, including streamed URL downloads. One page is '
                          'rendered at a time; raster output is capped at 16 million pixels and an '
                          '8192-pixel side, reducing quality at extreme zoom if necessary. Corrupt files, '
                          'CORS/access errors and password-protected documents show an error and allow '
                          'another file. No passwords, forms, annotations, signatures, PDF links, print, '
                          'OCR, thumbnails or built-in localization. PDF JavaScript/actions are not '
                          'executed.\n'
                          '\n'
                          'Flutter currently supports this component on Web only; native displays an '
                          'explicit unsupported message. Native support and full screen-reader certification '
                          'are not part of this release.'},
 'NgMap': {'title': 'Interactive map',
           'use': 'Display geographic markers, paths and polygons over an optional raster basemap.',
           'blazor': '<NgMap Label="Objects" Value="map" ClusterMarkers="true" ClusterRadius="60" '
                     '@bind-View="view" @bind-SelectedId="selected"\n'
                     '    OnMapClick="Clicked" '
                     'TileUrlTemplate="https://tile.openstreetmap.org/{z}/{x}/{y}.png"\n'
                     '    Attribution="© OpenStreetMap contributors" '
                     'AttributionUrl="https://www.openstreetmap.org/copyright"/>\n'
                     '<p>Selected: @selected; last point: @last</p>\n'
                     '@code {\n'
                     ' private string? selected; private string last="";\n'
                     ' private NgMapView view=new(50.4501,30.5234,13);\n'
                     ' private NgMapModel map=new(\n'
                     '   '
                     '[new("office","Office",new(50.4501,30.5234)),new("park","Park",new(50.4466,30.5410))],\n'
                     '   [new("line","Line",[new(50.4501,30.5234),new(50.4466,30.5410)])]);\n'
                     ' private void Clicked(NgMapPoint p){last=$"{p.Latitude:F4}, {p.Longitude:F4}";}\n'
                     '}',
           'dart': 'String? selected;\n'
                   "String last = '';\n"
                   'NgMapView view = NgMapView(latitude: 50.4501, longitude: 30.5234, zoom: 13);\n'
                   'final map = NgMapModel(markers: [\n'
                   "  NgMapMarker('office', 'Office', NgMapPoint(50.4501, 30.5234)),\n"
                   "  NgMapMarker('park', 'Park', NgMapPoint(50.4466, 30.5410)),\n"
                   "], paths: [NgMapPath('line', 'Line', [\n"
                   '  NgMapPoint(50.4501, 30.5234), NgMapPoint(50.4466, 30.5410),\n'
                   '])]);\n'
                   "Widget build(BuildContext context) => NgMap(label: 'Objects', value: map,\n"
                   '  view: view, selectedId: selected, clusterMarkers: true, clusterRadius: 60,\n'
                   '  onViewChanged: (v) => setState(() => view = v),\n'
                   '  onSelectedIdChanged: (id) => setState(() => selected = id),\n'
                   "  onMapClick: (p) => setState(() => last = '${p.latitude}, ${p.longitude}'),\n"
                   "  tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',\n"
                   "  attribution: '© OpenStreetMap contributors',\n"
                   "  attributionUrl: 'https://www.openstreetmap.org/copyright');",
           'notes': '### Hosting and tiles\n'
                    'Blazor requires interactive rendering and static assets. With UseStaticFiles map .mjs '
                    'to text/javascript for the clustering module (gallery Program.cs). Leaflet 1.9.4 is '
                    'packaged in map-viewer and Flutter assets; no CDN/script tags are needed. Flutter '
                    'implements Web; native shows an unsupported-platform message.\n'
                    '\n'
                    'TileUrlTemplate must contain {z}, {x}, {y}; relative and HTTP(S) URLs are supported. '
                    'Empty source shows a grid and your objects without a basemap. Attribution is required '
                    'for a configured provider; AttributionUrl adds a link. Attribution/object labels are '
                    'plain text. Choose a provider supporting zoom 0–19 and your usage terms. Custom '
                    'headers, bearer tokens, TMS and vector tiles are not supported.\n'
                    '\n'
                    'For OpenStreetMap keep attribution, normal Referrer and browser cache; do not '
                    'bulk-prefetch or download offline. The public service has no SLA; review the provider '
                    'terms and [tile policy](https://operations.osmfoundation.org/policies/tiles/). Object '
                    'labels are not sent to the provider, but IP, Referrer and tile coordinates are. Host '
                    'CSP must permit local frames/scripts/styles, Leaflet inline styles and provider '
                    'images.\n'
                    '\n'
                    '### Data model\n'
                    'NgMapPoint accepts latitude first, longitude second: finite latitude ±85.05112878, '
                    'longitude ±180. NgMapMarker has ID, label and position. NgMapPath is a straight '
                    'polyline with at least 2 points, or a closed polygon with at least 3; closing is '
                    'automatic. These are geographic lines, not road routing. No date-line crossing, holes '
                    'or multipolygons.\n'
                    '\n'
                    'NgMapModel copies collections and exposes read-only data. IDs are unique across markers '
                    'and paths: 1–64 ASCII letters/digits/_/-. Labels: 1–200 characters, not only '
                    'whitespace. Limits: 500 markers, 100 paths/polygons, 5,000 total path points. Invalid '
                    'input raises ArgumentException/ArgumentError. Replace the model to update; there is no '
                    'automatic persistence/loading.\n'
                    '\n'
                    '### View and events\n'
                    'View defines center and integer zoom 0–19 (initial 0,0,2). Drag pans; '
                    'wheel/double-click/+/- zoom. Focused maps accept arrows and +/-. Fit data fits all '
                    'objects with padding and zoom at most 14; empty models disable it. Data changes do not '
                    'auto-fit. The center is limited to world bounds.\n'
                    '\n'
                    'Store ViewChanged/onViewChanged after movement, zoom, fit or programmatic changes. '
                    'SelectedId is one object ID or null; selection callbacks report marker/path IDs or null '
                    'after Clear selection. Unknown IDs appear unselected without correcting parent state. '
                    'Objects buttons are keyboard accessible and open object popups; objects are also '
                    'clickable directly. OnMapClick reports a coordinate only for free background, not '
                    'object clicks. To add a marker, build a new NgMapModel with the old items and a '
                    'uniquely identified marker. No address/geocoding is returned.\n'
                    '\n'
                    'Height: 400–1200, default 520. Below 540 px the Objects list moves under the map and '
                    'scrolls horizontally. Label also names the iframe. Blazor Dark is explicit; Flutter '
                    'reads Theme. Theme/model updates preserve the iframe/view when View is unchanged; '
                    'provider imagery is not inverted.\n'
                    '\n'
                    '### Clustering\n'
                    'ClusterMarkers defaults to false. ClusterRadius is an integer 20–120 CSS px, default '
                    '60, validated even when clustering is off. Distance is screen distance at the current '
                    'zoom, not meters. Markers sort by ID and group around the first point; neighbor chains '
                    'do not merge indefinitely. Input ordering and panning do not change membership; zoom '
                    'recalculates groups. Date-line points are not clustered together.\n'
                    '\n'
                    'Activating a cluster zooms at least one level, up to 19. Coincident points or maximum '
                    'zoom open a scrollable member chooser. Choosing a member triggers normal selection and '
                    'displays its individual marker/popup. Clusters have no public object ID and do not '
                    'trigger background clicks. A selected marker stays outside clusters; Clear selection '
                    'rejoins it, so a cluster count excludes the selected marker while the total includes '
                    'every marker. Objects selection behaves the same way.\n'
                    '\n'
                    'Clusters support Tab/Enter and popup buttons. Data/clustering updates preserve the view '
                    'but may close a regrouped popup; theme changes retain groups. Paths are not clustered. '
                    'The 500-marker model limit still applies: this is not server aggregation. Dense markers '
                    'and Same location gallery scenarios demonstrate it without external tiles.\n'
                    '\n'
                    '### Status and omissions\n'
                    'No objects, No basemap configured, Loading tiles, Tiles loaded and Some map tiles '
                    'unavailable distinguish data and provider states. Objects/selection still work when '
                    'tiles fail. Navigation/source changes request new tiles. One raster basemap only; no '
                    'geocoding, routing, GeoJSON import, bubble layers, geometry editing, export or offline '
                    'mode. Filter large datasets in the application before supplying them.'},
 'NgPromptBox': {'title': 'Prompt input',
                 'use': 'Compose a multiline request with explicit submission and cancellation.',
                 'blazor': '<NgPromptBox Label="Prompt" @bind-Value="prompt" Busy="busy" OnSubmit="Submit" '
                           'OnCancel="Cancel"/>\n'
                           '<p>@result</p>\n'
                           '@code {\n'
                           ' private string prompt="",result=""; private bool busy; private int revision;\n'
                           ' private async Task Submit(string text) {\n'
                           '  var request=++revision; busy=true;\n'
                           '  await Task.Delay(700); // Local example; replace with an application handler.\n'
                           '  if(request!=revision)return;\n'
                           '  result=$"Received prompt: {text}"; busy=false;\n'
                           ' }\n'
                           ' private void Cancel(){revision++;busy=false;result="Cancelled";}\n'
                           '}',
                 'dart': "String prompt = '', result = '';\n"
                         'bool busy = false;\n'
                         'int revision = 0;\n'
                         'Future<void> submit(String text) async {\n'
                         '  final request = ++revision;\n'
                         '  setState(() => busy = true);\n'
                         '  await Future<void>.delayed(const Duration(milliseconds: 700));\n'
                         '  if (!mounted || request != revision) return;\n'
                         "  setState(() { result = 'Received prompt: $text'; busy = false; });\n"
                         '}\n'
                         "Widget build(BuildContext context) => NgPromptBox(label: 'Prompt', value: prompt,\n"
                         '  onChanged: (v) => setState(() => prompt = v), busy: busy,\n'
                         '  onSubmit: submit,\n'
                         "  onCancel: () => setState(() { revision++; busy = false; result = 'Cancelled'; "
                         '}));',
                 'notes': 'Value/value is a controlled draft. Store ValueChanged/onChanged and pass the '
                          'value back. External value replacement updates the field. MaxLength is 1–8000 '
                          'UTF-16 code units, default 8000; emoji may occupy two units. Values longer than '
                          'the limit are rejected. Blank input cannot be submitted. Send trims outer '
                          'whitespace; Enter inserts a newline. Tab followed by Enter/Space activates '
                          'buttons; no special submit shortcut is installed.\n'
                          '\n'
                          'Busy makes the input read-only and replaces Send with Cancel. The parent owns the '
                          'asynchronous request, busy state, result/error display and cancellation. OnCancel '
                          'only signals the parent: it does not stop a network request by itself. Use a '
                          'cancellation token/transport adapter and invalidate late responses. The example '
                          'demonstrates this ownership. ReadOnly prevents submission and editing; a busy '
                          'Cancel remains available when its callback exists. A missing submit/cancel '
                          'callback disables the corresponding action.\n'
                          '\n'
                          'This is an input control, not an AI client or form-validation engine. Use '
                          'NgAIPrompt for history and response actions. Attachments, speech input, model '
                          'selection, streaming and provider integration are not included. Do not put '
                          'provider secrets in browser code.'},
 'NgAIPrompt': {'title': 'AI prompt interface',
                'use': 'Compose requests, inspect responses and manage retries, history and feedback.',
                'blazor': '<NgAIPrompt Label="Assistant" @bind-Value="prompt" Generate="Generate"\n'
                          '    Suggestions="suggestions" OnCompleted="Completed" OnFeedback="Feedback"/>\n'
                          '<p>@status</p>\n'
                          '@code {\n'
                          ' private string prompt="Draft a meeting agenda",status="";\n'
                          ' private string[] suggestions=["Draft a meeting agenda","Suggest next steps"];\n'
                          ' private async Task<string> Generate(string text,CancellationToken cancellation) '
                          '{\n'
                          '  await Task.Delay(600,cancellation);\n'
                          '  return $"Local example response to: {text}"; // Connect your application '
                          'service here.\n'
                          ' }\n'
                          ' private void Completed(NgPromptResponse response){status=$"Response '
                          '{response.Id} ready";}\n'
                          ' private void Feedback(NgPromptFeedback feedback){status=$"Response feedback '
                          '{feedback.Response.Id}: {feedback.Helpful}";}\n'
                          '}',
                'dart': "String prompt = 'Draft a meeting agenda', status = '';\n"
                        'Future<String> generate(String text, NgPromptCancellation cancellation) async {\n'
                        '  await Future<void>.delayed(const Duration(milliseconds: 600));\n'
                        '  cancellation.throwIfCancelled();\n'
                        "  return 'Local example response to: $text'; // Replace with your application "
                        'service.\n'
                        '}\n'
                        "Widget build(BuildContext context) => NgAIPrompt(label: 'Assistant', value: "
                        'prompt,\n'
                        '  onChanged: (v) => setState(() => prompt = v), generate: generate,\n'
                        "  suggestions: const ['Draft a meeting agenda', 'Suggest next steps'],\n"
                        "  onCompleted: (r) => setState(() => status = 'Response ${r.id} ready'),\n"
                        "  onFeedback: (f) => setState(() => status = 'Response feedback ${f.response.id}: "
                        "${f.helpful}'));",
                'notes': '### Provider contract\n'
                         'Blazor Generate is Func<string,CancellationToken,Task<string>>; Flutter generate '
                         'is NgPromptGenerator: Future<String> Function(String,NgPromptCancellation). The '
                         'handler receives a captured, trimmed prompt and returns complete response text. '
                         'Without it the input is disabled. The example/gallery uses a deterministic delayed '
                         'local handler, not an AI model.\n'
                         '\n'
                         'The application owns authentication, model choice, rate limits, timeouts and '
                         'provider calls. Keep provider credentials on your backend. In Blazor pass '
                         'CancellationToken into the HTTP/AI client. In Flutter connect '
                         'cancellation.whenCancelled to transport cancellation; isCancelled and '
                         'throwIfCancelled detect cancellation. Checking after await stops result '
                         'processing, not the remote request or billing. The component itself makes no '
                         'network requests.\n'
                         '\n'
                         '### Draft and request lifecycle\n'
                         'Value/value and change callbacks control the draft. Maximum prompt: 8000 UTF-16 '
                         'units. Up to 8 nonempty suggestions, each at most 200 units. Suggestions fill the '
                         'draft without sending. Enter inserts a newline; Send submits. Duplicate submission '
                         'is blocked while busy. The user cannot edit during a request, but an external '
                         'Value replacement changes the next draft, not the captured request.\n'
                         '\n'
                         'Cancel immediately releases the UI and signals cancellation. A new request may '
                         'start immediately. Even if an older handler ignores cancellation, its late '
                         'result/error cannot enter history or replace newer state. Disposal, ReadOnly or '
                         'removing the handler also cancels pending work. ReadOnly keeps history '
                         "browsing/copying available. Transport cancellation is the application's "
                         'responsibility.\n'
                         '\n'
                         'Provider exceptions show a generic Generation failed. Try again. message; log '
                         'details in your handler. Retry request uses the last failed prompt even if the '
                         'draft changed. Empty/whitespace responses and responses over 32000 UTF-16 units '
                         'are errors. Previous successful history survives failures. Timeouts belong to the '
                         'application.\n'
                         '\n'
                         '### Responses and events\n'
                         'The last 20 successful responses are kept in memory; oldest entries are evicted. '
                         'IDs increase throughout the component session, including after Clear history. '
                         "Selecting history changes the displayed response. Regenerate runs that response's "
                         'original prompt. Clear removes history/selection/votes and cancels work in the '
                         'public session API; the UI button is disabled while busy. History is not durable '
                         'and is lost on component disposal.\n'
                         '\n'
                         'NgPromptResponse contains Id/id, Prompt/prompt and Text/text. OnCompleted fires '
                         'once for each accepted successful response, never for cancellation/failure. '
                         'NgPromptFeedback contains the response and Helpful/helpful: true, false or null '
                         'for a cleared vote. Clicking the same vote toggles it off; votes do not call the '
                         'provider. Callback exceptions belong to the host application.\n'
                         '\n'
                         'Responses render as plain text, with no HTML/Markdown execution. Copy response '
                         'uses the browser/platform clipboard; when unavailable, select the text manually. '
                         'Clipboard permissions and secure-context rules depend on the host. There are no '
                         'attachments, speech, command templates, streaming, provider SDKs, model picker, '
                         'durable conversations or automatic moderation.\n'
                         '\n'
                         '### Session API and integration\n'
                         'NgPromptSession exposes read-only Responses/responses, Selected/selected, '
                         'IsBusy/isBusy, Error/error and Status/status. RunAsync/run invokes a handler; '
                         'Cancel/cancel invalidates pending work; Select/select changes selection; '
                         'Clear/clear resets history; Dispose/dispose ends the session. Blazor Changed and '
                         'Flutter ChangeNotifier report state changes. Use it on the UI thread, dispose it '
                         'in its owner, and do not mutate response collections. The component owns its own '
                         'session; use the public session only when building a separate custom interface. '
                         'Native mobile and full accessibility certification remain separate.'},
 'NgStepper': {'title': 'Step progress',
               'use': 'Display progress through a sequence and request a different active step.',
               'blazor': '<NgStepper Items="steps" @bind-Value="current" Linear />\n'
                         '<p>Current index: @current</p>\n'
                         '@code {\n'
                         ' private int current;\n'
                         ' private NgStep[] '
                         'steps=[new("Contact"),new("Preferences",Optional:true),new("Review")];\n'
                         '}',
               'dart': 'int current = 0;\n'
                       "final steps = const [NgStep('Contact'), NgStep('Preferences', optional: true), "
                       "NgStep('Review')];\n"
                       'Widget build(BuildContext context) => NgStepper(items: steps, value: current, '
                       'linear: true,\n'
                       '  onChanged: (v) => setState(() => current = v));',
               'notes': 'Items/items contains 1–30 NgStep values. Labels must contain 1–120 UTF-16 units and '
                        'cannot be whitespace-only. Value/value is a zero-based enabled index. Invalid '
                        'configuration throws ArgumentException/ArgumentError instead of silently selecting '
                        'another step. Replace lists when updating them.\n'
                        '\n'
                        'NgStep contains Label/label, Disabled/disabled, Optional/optional and nullable '
                        'Valid/valid. Optional is an annotation, not an automatic skip. Valid is '
                        'presentation only: true shows a check mark, false shows Needs attention, null shows '
                        'the step number. It never performs validation. Disabled steps cannot be selected. '
                        'NgStepRules.Adjacent/adjacent finds the next enabled index in direction -1 or 1, '
                        'returning -1 at the boundary.\n'
                        '\n'
                        'Without Linear/linear, any enabled step can be selected. Linear permits any earlier '
                        'enabled step or the next enabled step, skipping disabled entries. It does not '
                        'remember the furthest visited step. Clicking the current step does nothing. Store '
                        'ValueChanged/onChanged in the parent; without updating Value the active marker '
                        'stays unchanged. Disabled disables all interaction. Vertical stacks the steps; '
                        'horizontal layout wraps on narrow screens.\n'
                        '\n'
                        'Use Tab to reach enabled buttons and Enter/Space to activate them. Blazor marks the '
                        'current step with aria-current=step; Flutter exposes selected semantics. Arrow-key '
                        'roving focus and full screen-reader certification are not implemented. Use NgWizard '
                        'to add content, validation and finish actions; this component itself does not mount '
                        'pages, validate fields or save data.'},
 'NgWizard': {'title': 'Multi-step wizard',
              'use': 'Guide a user through an application-owned form with guarded forward transitions and '
                     'completion.',
              'blazor': '<NgWizard Items="steps" @bind-Value="current" ValidateStep="Validate" '
                        'OnFinish="Save" Context="index">\n'
                        ' @if(index==0){<label>Name <input @bind="name" @bind:event="oninput" /></label>}\n'
                        ' else{<p>Review: @name</p>}\n'
                        '</NgWizard>\n'
                        '<p>@status</p>\n'
                        '@code {\n'
                        ' private int current; private string name="",status="Not saved";\n'
                        ' private NgStep[] steps=[new("Contact"),new("Review")];\n'
                        ' private Task<string?> Validate(int '
                        'index)=>Task.FromResult<string?>(index==0&&name.Trim().Length<2?"Enter at least two '
                        'characters.":null);\n'
                        ' private Task Save(){status=$"Saved: {name}";return Task.CompletedTask;}\n'
                        '}',
              'dart': 'int current = 0;\n'
                      "String name = '', status = 'Not saved';\n"
                      "final steps = const [NgStep('Contact'), NgStep('Review')];\n"
                      'Widget build(BuildContext context) => Column(children: [\n'
                      ' NgWizard(items: steps, value: current,\n'
                      '  onChanged: (v) => setState(() => current = v),\n'
                      "  validateStep: (index) async => index == 0 && name.trim().length < 2 ? 'Enter at "
                      "least two characters.' : null,\n"
                      "  onFinish: () async { setState(() => status = 'Saved: $name'); },\n"
                      '  contentBuilder: (context, index) => index == 0\n'
                      '    ? TextFormField(initialValue: name, decoration: const InputDecoration(labelText: '
                      "'Name'), onChanged: (v) => name = v)\n"
                      "    : Text('Review: $name')),\n"
                      ' Text(status),\n'
                      ']);',
              'notes': '### Configuration and state\n'
                       'Items and Value follow NgStepper rules: 1–30 steps, enabled zero-based current '
                       'index, unique positions and valid labels. Linear defaults to true. Back moves to the '
                       'preceding enabled step. Next moves to the following enabled step, skipping disabled '
                       'entries. Earlier headers are reachable; later headers obey Linear. With '
                       'Linear=false, clicking a later header validates only the current step, not every '
                       'skipped step. Optional is a label, not a separate Skip action.\n'
                       '\n'
                       'ValueChanged/onChanged is a request to the parent. Store it and render the returned '
                       'index; otherwise the wizard remains on the current step. ChildContent is '
                       'RenderFragment<int> in Blazor; contentBuilder is Widget Function(BuildContext,int) '
                       'in Flutter. Only active content is rendered. Keep drafts/controllers/validation keys '
                       'in the parent so data survives navigation; do not rely on child widget state. Blazor '
                       'consumers can key their content by index when they need fresh child instances.\n'
                       '\n'
                       '### Validation and asynchronous work\n'
                       'ValidateStep/validateStep receives the current index before forward movement (Next '
                       'or a future header) and before Finish. Return null or an empty string to allow the '
                       'action; return a user-facing message to block it. Backward movement does not '
                       'validate. Use EditContext.Validate or FormState.validate in this callback if '
                       'embedding a form; the wizard does not automatically validate nested fields. On '
                       'Finish, revalidate all business-critical values in your save service, including '
                       'earlier steps.\n'
                       '\n'
                       'During validation/saving, navigation buttons and headers are disabled and Checking… '
                       'is announced. Duplicate activation is ignored. Validation failure keeps the current '
                       'step and displays its message. Exceptions show a generic retryable error. A changed '
                       'current index, changed step configuration, disabled state or disposal invalidates '
                       'pending UI results, so an old validator cannot navigate a newly reset wizard. This '
                       'does not cancel network work: own transport cancellation in your application. '
                       'Vertical/theme changes alone preserve the pending operation.\n'
                       '\n'
                       '### Completion and reset\n'
                       'Finish appears when no later enabled step exists. It requires OnFinish/onFinish. '
                       'After successful completion it shows Completed. and disables further '
                       'navigation/saving. Failed saves remain retryable. Completion is local UI state, not '
                       'a server idempotency guarantee: use an idempotency key for durable operations. A '
                       'callback already running may still have external effects after disposal/reset; '
                       "protect your application's result updates accordingly.\n"
                       '\n'
                       'Use a new @key/ValueKey to reset the whole wizard, including completion, then reset '
                       'the parent draft/index. Changing the current index, step configuration or Disabled '
                       'also resets local status. The gallery demonstrates resetting while a delayed '
                       'validator is running. Do not change configuration during a durable save unless the '
                       'host handles its consequences.\n'
                       '\n'
                       '### Accessibility and scope\n'
                       'Tab and Enter/Space operate controls; status/error messages are announced. Stepper '
                       'orientation is horizontal/wrapping or vertical, above content. No automatic focus '
                       'move into the new form, custom button templates, side/bottom stepper placements, '
                       'built-in persistence, animated transitions or native/mobile certification. Keep the '
                       "form's visible headings and labels meaningful."}}

D.update({'NgMenu': {'title': 'Command menu',
            'use': 'Group related application commands in a horizontal toolbar or a vertical navigation '
                   'area. Open nested groups to choose a leaf action.',
            'notes': '### Connect commands to your application\n'
                     '\n'
                     'Pass a tree of NgMenuItem values. Each item has an ID, visible text, a disabled '
                     'flag and children. OnInvoke/onInvoke receives only an enabled leaf ID; opening a '
                     'group does not invoke an action. Store SelectedId/selectedId to mark the last '
                     'selected command. Use the handler to navigate, export or open a dialog. Text is '
                     'rendered as plain text; no URL is executed automatically.\n'
                     '\n'
                     '### Keyboard and layout\n'
                     '\n'
                     'Blazor uses a roving Tab stop, Left/Right in the horizontal bar, Up/Down in a '
                     'submenu or vertical bar, Home/End, Enter/Space to activate and Escape to close a '
                     'submenu and restore its opener. Down opens a top-level group; Right opens a '
                     'nested group. Flutter uses Material menu keyboard handling. Vertical switches the '
                     'root layout. Disabled groups block their descendants. An empty collection '
                     'displays No commands.\n'
                     '\n'
                     '### Data and platform limits\n'
                     '\n'
                     'Use globally unique IDs of 1–64 ASCII letters, digits, underscores or hyphens, '
                     'and nonblank labels of at most 120 UTF-16 code units. Trees allow at most three '
                     'levels and 100 total items. Children are copied into read-only collections. '
                     'Replace the root collection when changing configuration. Blazor requires an '
                     'interactive render mode and browser Popover API support; Chrome Web is the '
                     'verified target. Icons, arbitrary templates, context menus and automatic router '
                     'integration are outside this release.',
            'blazor': '<NgMenu Label="Document commands" Items="commands" SelectedId="@selected" '
                      'OnInvoke="Invoke" />\n'
                      '<p>Last command: @selected</p>\n'
                      '@code {\n'
                      '    private string? selected;\n'
                      '    private readonly NgMenuItem[] commands = [\n'
                      '        new("file", "File", children: [\n'
                      '            new("new", "New document"),\n'
                      '            new("export", "Export", children: [new("pdf", "PDF"), new("csv", '
                      '"CSV")]),\n'
                      '            new("delete", "Delete", disabled: true)\n'
                      '        ]), new("help", "Help")\n'
                      '    ];\n'
                      '    private void Invoke(string id) { selected = id; /* Dispatch the application '
                      'action. */ }\n'
                      '}',
            'dart': 'String? selected;\n'
                    'final commands = [\n'
                    "  NgMenuItem('file', 'File', children: [\n"
                    "    NgMenuItem('new', 'New document'),\n"
                    "    NgMenuItem('export', 'Export', children: [NgMenuItem('pdf', 'PDF'), "
                    "NgMenuItem('csv', 'CSV')]),\n"
                    "    NgMenuItem('delete', 'Delete', disabled: true),\n"
                    "  ]), NgMenuItem('help', 'Help'),\n"
                    '];\n'
                    'Widget build(BuildContext context) => Column(children: [\n'
                    "  NgMenu(label: 'Document commands', items: commands, selectedId: selected,\n"
                    '    onInvoke: (id) => setState(() => selected = id)),\n'
                    '  Text(\'Last command: ${selected ?? "None"}\'),\n'
                    ']);'},
 'NgDrawer': {'title': 'Navigation drawer',
              'use': 'Let users switch between application sections while keeping workspace content and '
                     'navigation state in the parent. Choose a modal overlay or a panel beside the '
                     'content.',
              'notes': '### Own the selected section and visibility\n'
                       '\n'
                       'Items uses NgOption: Value/value is the section ID, Label/label is visible '
                       'text, and Disabled/disabled prevents selection. Store SelectedId/selectedId and '
                       'Expanded/expanded in the parent. The built-in Open navigation button requests a '
                       'visibility change. An expanded overlay requires '
                       'ExpandedChanged/onExpandedChanged; the handler must store the new value and '
                       'rebuild. Otherwise a modal cannot be dismissed. Selection sends the ID first, '
                       'then requests closure in Overlay mode. Push mode stays open after selection.\n'
                       '\n'
                       '### Overlay and Push\n'
                       '\n'
                       'Overlay defaults to true: the panel covers the left side, prevents interaction '
                       'with the page, traps keyboard focus and closes on Escape, Close navigation or '
                       'the backdrop. Focus returns to the opener. Set Overlay/overlay to false for '
                       'Push: the panel shares the content layout and stacks above it below 600 logical '
                       'pixels. Flutter Push reserves 420 logical pixels of height and scrolls its '
                       'destinations. Width/width defaults to 260 and accepts 200–400; overlay width is '
                       'capped to the viewport minus 24 pixels.\n'
                       '\n'
                       '### Keep drafts and routing in your application\n'
                       '\n'
                       'The child content is application-owned. Keep form models or '
                       'TextEditingController instances in the parent; mode changes can rebuild child '
                       'elements. A selected ID marks the destination but does not create a URL or '
                       'route. A selected ID absent from Items simply leaves every destination '
                       'unselected. Empty Items displays No destinations. Flutter uses the root '
                       'Navigator for its modal route and removes only that route on disposal; use the '
                       'widget under MaterialApp. Blazor requires interactive rendering and native '
                       'dialog support.\n'
                       '\n'
                       '### Data limits and current scope\n'
                       '\n'
                       'Use up to 100 flat destinations with unique IDs of 1–64 ASCII letters, digits, '
                       'underscores or hyphens and nonblank labels of at most 120 UTF-16 code units. '
                       'Nested destinations, mini mode, custom item templates, swipe gestures and '
                       'native mobile validation are not included.',
              'blazor': '<NgDrawer Label="Workspace" Items="destinations" @bind-SelectedId="selected" '
                        '@bind-Expanded="expanded" Overlay="true">\n'
                        '    <h2>@selected</h2>\n'
                        '    <NgTextBox Label="Draft note" @bind-Value="note" />\n'
                        '</NgDrawer>\n'
                        '@code {\n'
                        '    private string? selected = "overview", note;\n'
                        '    private bool expanded;\n'
                        '    private readonly NgOption[] destinations = [new("overview", "Overview"), '
                        'new("reports", "Reports"), new("settings", "Settings", true)];\n'
                        '}',
              'dart': 'bool expanded = false;\n'
                      "String? selected = 'overview';\n"
                      'final note = TextEditingController();\n'
                      '@override void dispose() { note.dispose(); super.dispose(); }\n'
                      'Widget build(BuildContext context) => NgDrawer(\n'
                      "  label: 'Workspace', items: const [NgOption('overview', 'Overview'), "
                      "NgOption('reports', 'Reports'), NgOption('settings', 'Settings', disabled: "
                      'true)],\n'
                      '  selectedId: selected, onSelectedIdChanged: (id) => setState(() => selected = '
                      'id),\n'
                      '  expanded: expanded, onExpandedChanged: (value) => setState(() => expanded = '
                      'value),\n'
                      '  overlay: true,\n'
                      "  child: Column(children: [Text(selected ?? 'Choose a section'), "
                      "NgTextBox(label: 'Draft note', controller: note)]),\n"
                      ');'}})

D.update({'NgToggleButton': {'title': 'Toggle button',
                    'use': 'Switch a single setting on or off while keeping the action label visible. '
                           'Examples include a preview border, a pinned item or a formatting option.',
                    'notes': '### Bind the current state\n'
                             '\n'
                             'Value/value is a Boolean owned by the application. Blazor supports '
                             '@bind-Value; Flutter uses value with onChanged and setState. Each '
                             'activation requests the opposite value. The component does not save data '
                             'or change application state independently. Keep the label stable, such as '
                             'Show border, so its pressed state clearly explains whether the setting is '
                             'enabled.\n'
                             '\n'
                             '### Keyboard and disabled state\n'
                             '\n'
                             'Tab focuses the button. Enter or Space activates it. The control exposes '
                             'its pressed/checked state to accessibility APIs and keeps focus after a '
                             'change. Disabled/disabled blocks activation. A missing '
                             'ValueChanged/onChanged callback also disables the control, while external '
                             'value changes remain visible. This is a button, not a form submission '
                             'control.\n'
                             '\n'
                             '### Limits and composition\n'
                             '\n'
                             'Use a nonblank plain-text label up to 120 UTF-16 code units. Icon-only '
                             'content, arbitrary templates and separate click events are outside this '
                             'release. Use NgButtonGroup to coordinate several toggles; use NgSwitch '
                             'for a switch-shaped control. Web is the verified target; native mobile '
                             'validation remains separate.',
                    'blazor': '<NgToggleButton Label="Show border" @bind-Value="showBorder" />\n'
                              '<p>Border: @(showBorder ? "On" : "Off")</p>\n'
                              '@code { private bool showBorder; }',
                    'dart': 'bool showBorder = false;\n'
                            'Widget build(BuildContext context) => Column(children: [\n'
                            "  NgToggleButton(label: 'Show border', value: showBorder,\n"
                            '    onChanged: (value) => setState(() => showBorder = value)),\n'
                            '  Text(\'Border: ${showBorder ? "On" : "Off"}\'),\n'
                            ']);'},
 'NgButtonGroup': {'title': 'Single and multiple choice buttons',
                   'use': 'Present a small set of related settings as visible buttons. Use single '
                          'selection for alignment or a view mode, and multiple selection for '
                          'independent styles or filters.',
                   'notes': '### Choose a selection mode\n'
                            '\n'
                            'Items/items is a flat list of NgOption values. Value/value is a list of '
                            'selected IDs even in single-selection mode. Multiple/multiple defaults to '
                            'false: activating a different option replaces the previous selection. With '
                            'Multiple/multiple true, options toggle independently. The parent must '
                            'store ValueChanged/onChanged and pass the new list back. Changes produce a '
                            'new list in item order; input collections are never modified.\n'
                            '\n'
                            '### Decide whether users can clear the selection\n'
                            '\n'
                            'AllowEmpty/allowEmpty defaults to true, so clicking the last selected '
                            'button clears it. Set it to false to prevent a user from removing the last '
                            'choice. This rule does not create an initial selection and does not reject '
                            'an empty value supplied by the parent: initialize a value if your '
                            'application requires one. A prevented action emits no change event. '
                            'Unknown or disabled activation IDs are ignored by the selection rules.\n'
                            '\n'
                            '### Updates, disabled options and validation\n'
                            '\n'
                            'Each option has an ID, label and disabled flag. Disabled/disabled disables '
                            'the whole group; a missing callback also disables all buttons. A disabled '
                            'selected option remains visible. Selecting another item in single mode '
                            'replaces the prior selection, even if that prior item is disabled. '
                            'Programmatic reset remains possible while controls are disabled.\n'
                            '\n'
                            'IDs must be unique, contain 1–64 ASCII letters, digits, underscores or '
                            'hyphens, and labels must be nonblank with at most 120 UTF-16 code units. '
                            'Supply at most 50 options. Selected IDs must be unique and exist in '
                            'Items/items; single mode accepts at most one. When removing options or '
                            'switching to single mode, normalize the selected list in the same parent '
                            'update. Empty items with an empty value displays No options.\n'
                            '\n'
                            '### Layout and keyboard\n'
                            '\n'
                            'Horizontal groups wrap onto new lines on narrow screens. Vertical/vertical '
                            'stacks buttons. Tab and Shift+Tab move between enabled buttons; Enter and '
                            'Space activate them. Each button exposes its pressed state, and the group '
                            'has a shared accessible label. This is a group of toggle buttons, not an '
                            'arrow-key radiogroup. Routes, content panels, mixed command buttons, icons '
                            'and custom templates are outside this release. Use NgRadioGroup for radio '
                            'input semantics.',
                   'blazor': '<NgButtonGroup Label="Text alignment" Items="alignments" '
                             '@bind-Value="alignment" AllowEmpty="false" />\n'
                             '<NgButtonGroup Label="Text styles" Items="styles" @bind-Value="format" '
                             'Multiple />\n'
                             '<p>Alignment: @string.Join(", ", alignment). Styles: @string.Join(", ", '
                             'format)</p>\n'
                             '@code {\n'
                             '    private IReadOnlyList<string> alignment = ["left"], format = [];\n'
                             '    private readonly NgOption[] alignments = [new("left", "Left"), '
                             'new("center", "Center"), new("right", "Right")];\n'
                             '    private readonly NgOption[] styles = [new("bold", "Bold"), '
                             'new("italic", "Italic"), new("underline", "Underline", true)];\n'
                             '}',
                   'dart': "List<String> alignment = ['left'], format = [];\n"
                           "final alignments = const [NgOption('left', 'Left'), NgOption('center', "
                           "'Center'), NgOption('right', 'Right')];\n"
                           "final styles = const [NgOption('bold', 'Bold'), NgOption('italic', "
                           "'Italic'), NgOption('underline', 'Underline', disabled: true)];\n"
                           'Widget build(BuildContext context) => Column(children: [\n'
                           "  NgButtonGroup(label: 'Text alignment', items: alignments, value: "
                           'alignment,\n'
                           '    allowEmpty: false, onChanged: (value) => setState(() => alignment = '
                           'value)),\n'
                           "  NgButtonGroup(label: 'Text styles', items: styles, value: format, "
                           'multiple: true,\n'
                           '    onChanged: (value) => setState(() => format = value)),\n'
                           '  Text(\'Alignment: ${alignment.join(", ")}. Styles: ${format.join(", '
                           '")}\'),\n'
                           ']);'}})

D.update({'NgChip': {'title': 'Compact selectable or removable tag',
            'use': 'Show a short status, toggle a tag, or offer an explicit remove action.',
            'notes': '### State and events\n'
                     '\n'
                     'The parent owns Value/value and stores selection callbacks. '
                     'Selectable/selectable defaults to true. Disable it for a display-only label. '
                     'OnRemove/onRemove is optional: providing it shows a separate, named remove '
                     'action. Removal never changes selection or data automatically. Reject a '
                     'request by leaving state unchanged; accept it by removing the ID from both '
                     'items and selected values in one update. Removal does not fire the selection '
                     'callback. Keep durable state in the parent.\n'
                     '\n'
                     '### Keyboard and accessibility\n'
                     '\n'
                     'Selection and removal have separate accessible actions. Tab moves through '
                     'enabled actions; Enter or Space activates the focused action. Selected state '
                     'is exposed to assistive technology. Disabled chips cannot be selected or '
                     'removed. Native Flutter chip keyboard behavior includes its delete action. '
                     'Arrow-key list navigation and focus transfer after removing a focused item '
                     'are not implemented. Test screen-reader behavior in your target browser.\n'
                     '\n'
                     '### Scope\n'
                     '\n'
                     'Labels must be nonblank and at most 120 UTF-16 code units. Labels render as '
                     'text, never HTML. Light/dark styling and wrapping are supported. Icons, '
                     'avatars, custom templates, drag sorting, editable tags and virtualization '
                     'are deferred. Web is the verified target; mobile verification is a separate '
                     'phase.\n'
                     '\n'
                     'A missing selection callback prevents selection. Removal remains '
                     'independently available when supplied. For a static status, set '
                     'Selectable/selectable to false. Removing a standalone chip means the parent '
                     'stops rendering it.',
            'blazor': '@if (visible) {\n'
                      '    <NgChip Label="Favourite" @bind-Value="selected" '
                      'OnRemove="()=>visible=false" />\n'
                      '}\n'
                      '<NgChip Label="Published" Selectable="false" />\n'
                      '@code {\n'
                      '    private bool selected, visible = true;\n'
                      '}',
            'dart': 'bool selected = false, visible = true;\n'
                    'Widget build(BuildContext context) => Wrap(spacing: 8, children: [\n'
                    "  if (visible) NgChip(label: 'Favourite', value: selected,\n"
                    '    onChanged: (v) => setState(() => selected = v),\n'
                    '    onRemove: () => setState(() => visible = false)),\n'
                    "  const NgChip(label: 'Published', selectable: false),\n"
                    ']);'},
 'NgChipList': {'title': 'Controlled tag collection',
                'use': 'Present filter topics or selected tags with single/multiple selection and '
                       'application-owned removal.',
                'notes': '### State and events\n'
                         '\n'
                         'The parent owns Value/value and stores selection callbacks. '
                         'Selectable/selectable defaults to true. Disable it for a display-only '
                         'label. OnRemove/onRemove is optional: providing it shows a separate, '
                         'named remove action. Removal never changes selection or data '
                         'automatically. Reject a request by leaving state unchanged; accept it by '
                         'removing the ID from both items and selected values in one update. '
                         'Removal does not fire the selection callback. Keep durable state in the '
                         'parent.\n'
                         '\n'
                         '### Keyboard and accessibility\n'
                         '\n'
                         'Selection and removal have separate accessible actions. Tab moves '
                         'through enabled actions; Enter or Space activates the focused action. '
                         'Selected state is exposed to assistive technology. Disabled chips cannot '
                         'be selected or removed. Native Flutter chip keyboard behavior includes '
                         'its delete action. Arrow-key list navigation and focus transfer after '
                         'removing a focused item are not implemented. Test screen-reader behavior '
                         'in your target browser.\n'
                         '\n'
                         '### Scope\n'
                         '\n'
                         'Labels must be nonblank and at most 120 UTF-16 code units. Labels render '
                         'as text, never HTML. Light/dark styling and wrapping are supported. '
                         'Icons, avatars, custom templates, drag sorting, editable tags and '
                         'virtualization are deferred. Web is the verified target; mobile '
                         'verification is a separate phase.\n'
                         '\n'
                         '### Collection contract\n'
                         '\n'
                         'Use NgOption IDs, not display labels. IDs must be unique, 1–64 ASCII '
                         'letters, digits, underscores or hyphens. Up to 50 items are supported. '
                         'Selected IDs must be unique and exist in items; single mode accepts at '
                         'most one. Multiple/multiple defaults to false. AllowEmpty/allowEmpty '
                         'defaults to true; false prevents deselecting the last choice, but does '
                         'not invent an initial selection or block application-owned removal. '
                         'Callbacks return IDs in item order. No-op selection does not emit a '
                         'callback. Empty items with empty value displays No tags.\n'
                         '\n'
                         'When switching from multiple to single selection, normalize the '
                         'selection in the same update. Disabled selected items stay visible; '
                         'another single choice can replace them. The example below removes both '
                         'the item and its selected ID atomically. For async removal, hold state '
                         'until success and disable controls while pending.',
                'blazor': '<NgChipList Label="Topics" Items="items" @bind-Value="selected" '
                          'Multiple OnRemove="Remove" />\n'
                          '@code {\n'
                          '    private IReadOnlyList<NgOption> items = [new("design", "Design"), '
                          'new("web", "Web"), new("locked", "Locked", true)];\n'
                          '    private IReadOnlyList<string> selected = ["design"];\n'
                          '    private void Remove(string id) {\n'
                          '        items = items.Where(item => item.Value != id).ToArray();\n'
                          '        selected = selected.Where(value => value != id).ToArray();\n'
                          '    }\n'
                          '}',
                'dart': "List<NgOption> items = const [NgOption('design', 'Design'), "
                        "NgOption('web', 'Web'), NgOption('locked', 'Locked', disabled: true)];\n"
                        "List<String> selected = ['design'];\n"
                        "Widget build(BuildContext context) => NgChipList(label: 'Topics', items: "
                        'items,\n'
                        '  value: selected, multiple: true,\n'
                        '  onChanged: (v) => setState(() => selected = v),\n'
                        '  onRemove: (id) => setState(() {\n'
                        '    items = items.where((item) => item.value != id).toList();\n'
                        '    selected = selected.where((value) => value != id).toList();\n'
                        '  }));'}})

# 0.15: appearance, templates and independent command events.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] = D[name]['notes'].replace('Icons, avatars, custom templates, drag sorting, editable tags and virtualization are deferred.', 'Icons and avatars can be supplied as leading content, and custom labels and remove icons are supported. Drag sorting, editable tags and virtualization are not established Telerik Chip/ChipList requirements and remain possible extensions, not parity claims.')
    D[name]['notes'] += """

### Appearance and custom content (0.15)

Size/size accepts sm, md or lg. Rounded/rounded accepts sm, md, lg or full. FillMode/fillMode accepts solid or outline. ThemeColor/themeColor accepts base, info, success, warning or error. Invalid values throw; defaults remain md/full/outline/base for compatibility with 0.14. These defaults differ from Telerik. Colors adapt to light/dark themes; this is not a pixel-match claim.

Leading/leading accepts decorative content such as a small icon or avatar. ChildContent/child replaces the visible label. RemoveContent/removeIcon replaces the removal symbol. Always retain a meaningful Label/label: it supplies the accessible name regardless of the visual template. Do not put buttons, links, text fields or other interactive controls inside these templates. The parent owns image loading and image errors; there is no built-in avatar downloader or Telerik SVG icon registry.

OnClick/onClick is independent of selection: it runs after the selection callback on activation, also when selection is disabled. Removal only invokes the remove callback. Disabled chips invoke neither. A missing selection callback keeps selection unchanged, while an available click callback can still run a command. Blazor awaits the selection handler before invoking click; the next boolean is calculated before either callback. Flutter callbacks are synchronous. Do not use click to toggle selection a second time.
"""
D['NgChipList']['notes'] += """

### Per-item presentation

ItemTemplate/itemBuilder and LeadingTemplate/leadingBuilder receive NgOption. ItemAppearance/itemAppearance returns NgChipAppearance: its nullable size, rounded, fill mode and theme color override list defaults independently. CanRemove/canRemove hides the remove action for selected items without disabling selection. It defaults to true and still requires the list removal callback. This predicate controls availability; reject a permitted request by leaving parent state unchanged. Functions should be pure, because rendering can evaluate them again.

This is a typed NgOption adapter contract, not Telerik generic model reflection or property-name binding. Map application data to NgOption and resolve additional fields by stable ID in the template. The current 50-item limit and keyboard/listbox differences are tracked in the feature parity matrix.
"""
D['NgChip']['blazor'] = '<NgChip Label="Build succeeded" Selectable="false" ThemeColor="success" FillMode="solid" Size="lg" Rounded="md" OnClick="()=>clicks++">\n    <Leading><span>✓</span></Leading>\n    <ChildContent><strong>Build succeeded</strong></ChildContent>\n</NgChip>\n@if (visible) {\n    <NgChip Label="Favourite" @bind-Value="selected" OnRemove="()=>visible=false">\n        <RemoveContent>−</RemoveContent>\n    </NgChip>\n}\n<p>Activity opened @clicks times</p>\n@code {\n    private bool selected, visible = true;\n    private int clicks;\n}'
D['NgChip']['dart'] = "bool selected = false, visible = true;\nint clicks = 0;\nWidget build(BuildContext context) => Wrap(spacing: 8, children: [\n  NgChip(label: 'Build succeeded', selectable: false, themeColor: 'success',\n    fillMode: 'solid', size: 'lg', rounded: 'md', leading: const Icon(Icons.check, size: 18),\n    child: const Text('Build succeeded'), onClick: () => setState(() => clicks++)),\n  if (visible) NgChip(label: 'Favourite', value: selected,\n    onChanged: (v) => setState(() => selected = v),\n    removeIcon: const Icon(Icons.remove, size: 18),\n    onRemove: () => setState(() => visible = false)),\n  Text('Activity opened $clicks times'),\n]);"
D['NgChipList']['blazor'] = D['NgChipList']['blazor'].replace('Multiple OnRemove="Remove" />', 'Multiple OnRemove="Remove" CanRemove="item=>item.Value!=\"locked\"" FillMode="solid" ItemAppearance="item=>new NgChipAppearance(ThemeColor:item.Value==\"design\"?\"info\":\"base\")"><ItemTemplate Context="item"><strong>@item.Label</strong></ItemTemplate><LeadingTemplate><span>★</span></LeadingTemplate></NgChipList>')
D['NgChipList']['dart'] = D['NgChipList']['dart'].replace('value: selected, multiple: true,', "value: selected, multiple: true, fillMode: 'solid',\n  canRemove: (item) => item.value != 'locked',\n  itemAppearance: (item) => NgChipAppearance(themeColor: item.value == 'design' ? 'info' : 'base'),\n  itemBuilder: (item) => Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),\n  leadingBuilder: (_) => const Icon(Icons.star, size: 18),")

D['NgChipList']['blazor'] = D['NgChipList']['blazor'].replace('CanRemove="item=>item.Value!=\"locked\""', 'CanRemove="@(item=>item.Value!=\"locked\")"').replace('ItemAppearance="item=>new NgChipAppearance(ThemeColor:item.Value==\"design\"?\"info\":\"base\")"', 'ItemAppearance="@(item=>new NgChipAppearance(ThemeColor:item.Value==\"design\"?\"info\":\"base\"))"')

# 0.16: keyboard and focus behavior, with explicit remaining ARIA differences.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] = D[name]['notes'].replace('Native Flutter chip keyboard behavior includes its delete action.', 'Delete or Backspace requests removal from a focused interactive chip. Holding the key does not repeatedly remove chips.')
    D[name]['notes'] = D[name]['notes'].replace('Arrow-key list navigation and focus transfer after removing a focused item are not implemented.', 'ChipList adds Left/Right and Home/End navigation with focus recovery after removal; see the keyboard rules below.')
D['NgChipList']['notes'] += """

### Keyboard and focus (0.16)

Left/Right moves to the adjacent enabled interactive chip, reversing direction in RTL. Home/End focuses the first/last available chip. Navigation clamps at the ends and does not change selection. Enter/Space activates selection and click. Delete/Backspace requests removal if allowed; a nonremovable chip keeps focus. Modified shortcuts (Alt/Ctrl/Meta) are left to the application. Repeated deletion keydown is ignored.

After accepted removal of the focused item, focus moves to the next enabled item at the former position, otherwise the nearest previous enabled item. When none remains, the named list container receives focus. A rejected request keeps focus. Delayed data updates do not pull focus back when the user has moved to another control. Stable IDs preserve focus on reorder. Changing a focused item to disabled uses the same fallback. Do not reuse IDs for unrelated records.

Since 0.17, the list has one Tab stop. On first entry, focus goes to the first selected enabled interactive chip, otherwise the first available chip. Arrows change the remembered entry without changing selection. Tab leaves the list; Shift+Tab returns to that entry. If it disappears or becomes disabled, the entry falls back to a selected enabled chip or the first available chip. Empty and fully disabled lists add no Tab stop. Use Delete/Backspace to request removal; removal icons remain available to pointer and assistive-technology actions. Custom templates should contain display content, not extra interactive controls.

Single Tab entry does not imply full listbox semantics: Blazor still exposes a group of pressed buttons, Flutter its native chip semantics. Flutter SDK used for this release lacks listbox/option roles. Those roles, public accessibility hooks and screen-reader validation remain explicit gaps in the parity matrix.

Blazor exposes FocusAsync() on NgChipList via @ref after interactive rendering. It focuses the first available action or the list container. The JS module is initialized automatically and disposed with the component. Flutter owns and disposes internal focus nodes; a public list focus controller is still pending.

Blazor serializes pending remove callbacks. Flutter removal callbacks remain synchronous requests: if the application performs async deletion, it must handle duplicate requests, errors and cancellation, then update items and selected IDs together. Focus restoration tracks that later state update; it does not await network operations. Removing a standalone chip requires the application to move focus explicitly.
"""

# 0.18: application focus and translatable action/empty labels.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] += """

### Action labels (0.18)

NgChip.RemoveLabel / removeLabel overrides the complete accessible removal name and Flutter delete tooltip. Null keeps "Remove {label}". Supply a nonblank phrase including the item name, such as "Dismiss Design"; a visual remove icon alone is not an accessible name. Text is escaped, not treated as markup. Obtain translations from your application's localization resources; the library does not select a locale or ship translation dictionaries.
"""
D['NgChipList']['notes'] = D['NgChipList']['notes'].replace('Flutter owns and disposes internal focus nodes; a public list focus controller is still pending.', 'Flutter owns and disposes internal focus nodes; use the public NgChipListController described below.')
D['NgChipList']['notes'] += """

For lists, RemoveLabel (Blazor) / removeLabelBuilder (Flutter) receives each NgOption and supplies that chip's removal phrase. Keep the callback pure. EmptyText / emptyText changes the empty collection message; the default remains "No tags" and blank text is rejected. Label / label still supplies the list name. Changing these strings does not change IDs, selection or removal permissions. Changing the application locale must trigger a normal parent rerender/rebuild. RTL direction is inherited from the surrounding HTML direction or Flutter Directionality; these label hooks do not set direction.

### Focus from application code (0.18)

Blazor: keep an @ref and await FocusAsync() after interactive rendering. It focuses the first enabled action, or the list container when none exists. Calling before initialization is a no-op.

Flutter: create one NgChipListController in the owning State, pass it as focusController, and dispose it in that State's dispose(). Never create a controller inside build or share one between simultaneous lists. A shared or previously disposed controller throws StateError on attachment. Changing focusController detaches the old handle; removing the list detaches it automatically. The list continues to own its internal FocusNodes.

focus() requests the first enabled interactive chip, or the container for an empty/all-disabled list. focus(itemId: 'web') targets an enabled interactive chip by stable ID. It returns false without moving focus if detached, disposed, not yet laid out, or if the explicit ID is missing/disabled. A true return means a focus request was issued; Flutter applies it on the next frame. isAttached reports attachment, not layout readiness. Call from an event callback or a post-frame callback after mounting. Focus never changes selection or invokes click/removal callbacks. The example intentionally uses English custom labels; substitute application translations as needed.
"""
D['NgChipList']['blazor'] = '''<NgChipList @ref="topics" Label="Topics" Items="items" @bind-Value="selected"
    Multiple OnRemove="Remove" RemoveLabel="RemoveLabel" EmptyText="No topics available" />
<NgButton OnClick="FocusTopics">Focus topics</NgButton>
@code {
    private NgChipList? topics;
    private IReadOnlyList<NgOption> items = [new("design", "Design"), new("web", "Web"), new("locked", "Locked", true)];
    private IReadOnlyList<string> selected = ["design"];
    private string RemoveLabel(NgOption item) => $"Dismiss {item.Label}";
    private async Task FocusTopics() { if (topics is not null) await topics.FocusAsync(); }
    private void Remove(string id) {
        items = items.Where(item => item.Value != id).ToArray();
        selected = selected.Where(value => value != id).ToArray();
    }
}'''
D['NgChipList']['dart'] = '''final topics = NgChipListController();
List<NgOption> items = const [NgOption('design', 'Design'), NgOption('web', 'Web'), NgOption('locked', 'Locked', disabled: true)];
List<String> selected = ['design'];
@override
void dispose() { topics.dispose(); super.dispose(); }
Widget build(BuildContext context) => Column(children: [
  NgChipList(label: 'Topics', focusController: topics, items: items,
    value: selected, multiple: true, emptyText: 'No topics available',
    removeLabelBuilder: (item) => 'Dismiss ${item.label}',
    onChanged: (v) => setState(() => selected = v),
    onRemove: (id) => setState(() {
      items = items.where((item) => item.value != id).toList();
      selected = selected.where((value) => value != id).toList();
    })),
  NgButton(onPressed: () => topics.focus(), child: const Text('Focus topics')),
  NgButton(onPressed: () => topics.focus(itemId: 'web'), child: const Text('Focus Web')),
]);'''

D['NgChipList']['notes'] = D['NgChipList']['notes'].replace('Tab moves through enabled actions;', 'Tab enters the list once and then leaves; arrows move inside;').replace('focus() requests the first enabled interactive chip, or the container for an empty/all-disabled list.', 'focus() requests the first enabled interactive chip, or the container for an empty/all-disabled list. The Flutter container shows a focus outline when it receives primary focus.')

# 0.19: remove the ChipList-specific collection cap, keeping other controls' limits.
D['NgChipList']['notes'] = D['NgChipList']['notes'].replace('Up to 50 items are supported.', 'Since 0.19, ChipList has no fixed item-count cap.').replace('The current 50-item limit and keyboard/listbox differences are tracked in the feature parity matrix.', 'ChipList no longer has a fixed item-count cap; remaining keyboard/listbox differences are tracked in the feature parity matrix.')
D['NgChipList']['notes'] += """

### Larger collections (0.19)

The Web demo and interaction tests cover 500 tags, including disabled items, selection, Home/End and removal with focus recovery. Data-rule tests additionally cover 5,000 records in Flutter; that is not a rendering or performance guarantee. All chips are rendered eagerly and retain their own focus state. There is no virtualization, lazy fetching or automatic paging. For thousands of visible records, filter the application data or use a data-oriented control and measure on your target device. The limit removal does not imply unlimited practical capacity.

IDs still must be unique and valid, labels must be nonblank and at most 120 UTF-16 code units, and selected IDs must exist in the current items. Update items and value together when filtering/removing records; do not leave selected IDs outside the supplied collection. Selection validation and membership checks use sets rather than rescanning the entire list per selected ID. ButtonGroup retains its 50-option limit and Drawer its 100-item limit.

Flutter scrolls focused chips into ancestor scrollable viewports when keyboard or application focus moves. Put the list inside a bounded scrollable page, as in the gallery. Blazor uses native browser scrolling on focus. Keep templates display-only and prefer short labels. The Load 500 tags example resets selection deliberately; adapt this policy to your application.
"""
D['NgChipList']['blazor'] = D['NgChipList']['blazor'].replace('<NgButton OnClick="FocusTopics">Focus topics</NgButton>', '<NgButton OnClick="FocusTopics">Focus topics</NgButton>\n<NgButton OnClick="LoadTags">Load 500 tags</NgButton>').replace('    private NgChipList? topics;', '''    private NgChipList? topics;
    private void LoadTags() {
        items = Enumerable.Range(1, 500).Select(i => new NgOption($"tag{i}", $"Topic {i}", i % 10 == 0)).ToArray();
        selected = ["tag1"];
    }''')
D['NgChipList']['dart'] = D['NgChipList']['dart'].replace('Widget build(BuildContext context) => Column(children: [', '''void loadTags() => setState(() {
  items = List.generate(500, (i) => NgOption('tag${i + 1}', 'Topic ${i + 1}', disabled: (i + 1) % 10 == 0));
  selected = ['tag1'];
});
Widget build(BuildContext context) => SingleChildScrollView(child: Column(children: [''').replace("  NgButton(onPressed: () => topics.focus(),", "  NgButton(onPressed: loadTags, child: const Text('Load 500 tags')),\n  NgButton(onPressed: () => topics.focus(),").replace(']);', ']));')

# 0.20: typed application data, with controlled selection and removal.
D['NgChipList']['notes'] += """

### Bind business records (0.20)

Create NgChipData<T> once for each data snapshot. Required value/text selectors map stable IDs and accessible labels. Optional disabled (default false), removable (default true) and appearance selectors map behavior and nullable style overrides. Each selector runs once per record when constructing the adapter. Pass Items/items, CanRemove/canRemove and GetAppearance/getAppearance to ChipList explicitly; the adapter does not attach itself to a widget.

GetItem(id)/getItem(id) returns the original record for templates and click/removal handlers. Resolve it before deleting or rebuilding the snapshot. Unknown IDs throw KeyNotFoundException in Blazor and ArgumentError in Flutter. Duplicate or invalid IDs, blank/oversized labels and invalid appearance values fail at construction. There is no fixed collection cap. IDs are case-sensitive and must be 1–64 ASCII letters, digits, underscores or hyphens.

The options collection is read-only; original records are not deep-cloned. After editing fields, adding, removing or reordering records, construct a new adapter. Keep stable IDs to preserve selection and keyboard identity. When removing records, update the selected IDs in the same state update. Disabled guards belong to ChipList; removable only controls the remove action, not selection. Omit OnRemove/onRemove for a read-only removal policy.

The following example pins Finance, disables Archive and resolves an owner from the clicked record. This is a typed-selector alternative to property-name reflection; there are no string field-name parameters. Icons and additional fields can be rendered through ItemTemplate/itemBuilder using GetItem/getItem. Templates must remain noninteractive. The Business records demo additionally exercises rename, reverse and reset without changing IDs.
"""
D['NgChipList']['blazor'] = '''<NgChipList Label="Business topics" Items="data.Items" @bind-Value="selected"
    Multiple CanRemove="data.CanRemove" ItemAppearance="data.GetAppearance"
    OnClick="Open" OnRemove="Remove" />
<p role="status">@message</p>
@code {
    private sealed record Topic(string Id, string Name, string Owner, bool Pinned = false, bool Disabled = false);
    private List<Topic> records = [new("ops", "Operations", "Morgan"), new("finance", "Finance", "Alex", Pinned: true), new("archive", "Archive", "Sam", Disabled: true)];
    private IReadOnlyList<string> selected = ["finance"];
    private NgChipData<Topic> data = default!;
    private string message = "Select a topic";
    protected override void OnInitialized() => Rebind();
    private void Rebind() => data = new(records, x => x.Id, x => x.Name,
        disabled: x => x.Disabled, removable: x => !x.Pinned,
        appearance: x => new(ThemeColor: x.Pinned ? "success" : "base"));
    private void Open(string id) => message = $"Owner: {data.GetItem(id).Owner}";
    private void Remove(string id) {
        message = $"Removed {data.GetItem(id).Name}";
        records = records.Where(x => x.Id != id).ToList();
        selected = selected.Where(x => x != id).ToArray();
        Rebind();
    }
}'''
D['NgChipList']['dart'] = '''List<({String id, String name, String owner, bool pinned, bool disabled})> records = [
  (id: 'ops', name: 'Operations', owner: 'Morgan', pinned: false, disabled: false),
  (id: 'finance', name: 'Finance', owner: 'Alex', pinned: true, disabled: false),
  (id: 'archive', name: 'Archive', owner: 'Sam', pinned: false, disabled: true),
];
List<String> selected = ['finance'];
String message = 'Select a topic';
late var data = bind();
// Explicit record type keeps event handlers statically checked.
NgChipData<({String id, String name, String owner, bool pinned, bool disabled})> bind() => NgChipData(records, value: (x) => x.id, text: (x) => x.name,
  disabled: (x) => x.disabled, removable: (x) => !x.pinned,
  appearance: (x) => NgChipAppearance(themeColor: x.pinned ? 'success' : 'base'));
Widget build(BuildContext context) => Column(children: [
  NgChipList(label: 'Business topics', items: data.items, value: selected,
    multiple: true, canRemove: data.canRemove, itemAppearance: data.getAppearance,
    onChanged: (v) => setState(() => selected = v),
    onClick: (id) => setState(() => message = 'Owner: ${data.getItem(id).owner}'),
    onRemove: (id) => setState(() {
      message = 'Removed ${data.getItem(id).name}';
      records = records.where((x) => x.id != id).toList();
      selected = selected.where((x) => x != id).toList();
      data = bind();
    })),
  Text(message),
]);'''


# 0.21: direction is inherited from a scoped platform container.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] += """

### Right-to-left layout (0.21)

Blazor inherits the nearest HTML dir attribute. Wrap a component or a group in a div with dir="rtl" (or dir="ltr"). Flutter inherits Directionality: wrap a component or group with Directionality(textDirection: TextDirection.rtl, child: ...). Keep the direction wrapper outside NgChipList so layout and keyboard handling read the same direction. No data reversal is required. Mixed LTR/RTL regions may coexist; omit the wrapper to inherit the application setting.

Chips start at the reading edge and wrap in source order. Leading content appears at the reading start, removal at the reading end, and the Blazor separator follows that edge. Changing direction at runtime preserves stable IDs, selection and the remembered keyboard entry. In RTL, Left moves to the next enabled record and Right to the previous; Home/End still target the first/last enabled record in data order. Removal keeps the existing next/previous focus policy, including wrapped rows. Up/Down spatial navigation is not provided.

Direction changes layout; it does not translate labels or reverse application strings. Supply translated labels and RemoveLabel/removeLabel (or the list callback) and EmptyText/emptyText yourself. Use bdi/dir on a Blazor template or a nested Directionality/Text.textDirection in Flutter to isolate mixed-direction identifiers when appropriate. Directional custom icons are application-owned; they are not automatically mirrored. Keep templates noninteractive.

The English Reading direction demo includes a constrained wrapping region, decorative leading stars, a disabled record, a static status chip and a runtime direction switch. The rest of the demo remains LTR. Verification covers Chip/ChipList layout and keyboard behavior on Web, not every component or screen-reader pronunciation.
"""
D['NgChipList']['blazor'] = '<NgCheckBox Label="Right-to-left layout" @bind-Value="rtl" />\n<div dir="@(rtl ? "rtl" : "ltr")">\n' + D['NgChipList']['blazor'].replace('<p role="status">', '</div>\n<p role="status">').replace('@code {', '@code {\n    private bool rtl = false;')
D['NgChipList']['dart'] = D['NgChipList']['dart'].replace("String message = 'Select a topic';", "bool rtl = false;\nString message = 'Select a topic';").replace("  NgChipList(label: 'Business topics'", "  NgCheckBox(label: 'Right-to-left layout', value: rtl, onChanged: (v) => setState(() => rtl = v)),\n  Directionality(textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,\n    child: NgChipList(label: 'Business topics'").replace('      data = bind();\n    })),', '      data = bind();\n    }))),')

# 0.22: platform-native identity and accessible contextual help.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] += """

### Identity, accessible names and contextual help (0.22)

Blazor Id identifies the outer component element, and Class appends application CSS classes while preserving built-in classes. Neither creates a focus target or changes keyboard behavior. Supply unique IDs per rendered instance; Id must be nonblank and contain no whitespace. Classes can affect layout and contrast, so review custom styles in both themes.

AriaLabelledBy accepts one or more space-separated IDs of existing elements. Browser accessible-name computation gives these references priority over Label. Keep Label meaningful as the visible text/fallback, and ensure every referenced element exists. AriaDescribedBy accepts a similar list for contextual instructions. On ChipList, naming and description apply to the group; they are not duplicated on every item. On a standalone Chip, references apply to its label element/action, and the description also applies to removal. The remove action retains its own RemoveLabel; it never borrows the selection action's name. Static text chips remain noninteractive; when a Blazor static chip has naming/description references, its label becomes a named group without a Tab stop so the references have a semantic target. Null omits a hook; blank reference lists are rejected. The library cannot validate DOM existence or global ID uniqueness during server rendering.

Flutter semanticIdentifier identifies a semantics node for automation; it is not a widget Key, HTML id, user-facing label or selection ID. semanticHint provides contextual guidance in that node's semantics. Both are optional nonblank strings. On Web, the installed Flutter engine exports identifiers as flt-semantics-identifier attributes when semantics are enabled; this is an engine detail, not a CSS styling API. Metadata is additive: it must not replace the child selection/removal actions.

Flutter has no DOM Class or aria-labelledby relationship in this API. Use the existing theme/appearance parameters for styling. For a shared heading, keep one application string and pass it to Text and the list's label; update both together. Use semanticHint for concise guidance and show the same text visibly when it helps users. A hint is not an exact aria-describedby equivalent; assistive-technology announcement varies by platform. Application code owns translations. Do not include secrets or personal data in automation identifiers.

The examples wire contextual help to the list and a standalone command. The Business records demo can update its heading and guidance at runtime while retaining selection and identity. Browser accessibility-tree inspection and widget tests verify the exported information and actions; screen-reader testing/certification remains separate. Configurable TabIndex and listbox/option roles are still not supplied.
"""
D['NgChip']['blazor'] = '<p id="build-help">Opens the build activity summary.</p>\n' + D['NgChip']['blazor'].replace('<NgChip Label="Build succeeded"', '<NgChip Id="build-status" Class="build-status" AriaDescribedBy="build-help" Label="Build succeeded"')
D['NgChip']['dart'] = D['NgChip']['dart'].replace("NgChip(label: 'Build succeeded',", "NgChip(semanticIdentifier: 'build-status', semanticHint: 'Opens the build activity summary.', label: 'Build succeeded',")
D['NgChipList']['blazor'] = '<h2 id="topics-heading">Business topics</h2>\n<p id="topics-help">Choose topics for this workspace.</p>\n' + D['NgChipList']['blazor'].replace('<NgChipList Label="Business topics"', '<NgChipList Id="business-topics" Class="business-topics" AriaLabelledBy="topics-heading" AriaDescribedBy="topics-help" Label="Business topics"')
D['NgChipList']['dart'] = D['NgChipList']['dart'].replace('bool rtl = false;', "final heading = 'Business topics';\nfinal help = 'Choose topics for this workspace.';\nbool rtl = false;").replace('Widget build(BuildContext context) => Column(children: [', 'Widget build(BuildContext context) => Column(children: [\n  Text(heading), Text(help),').replace("NgChipList(label: 'Business topics'", "NgChipList(semanticIdentifier: 'business-topics', semanticHint: help, label: heading")

# 0.23: safe traversal participation and spacing presets.
for name in ('NgChip', 'NgChipList'):
    D[name]['notes'] = D[name]['notes'].replace('Configurable TabIndex and listbox/option roles are still not supplied.', 'TabIndex supports -1 and 0 since 0.23; listbox/option roles remain open.')
    D[name]['notes'] += """

### Participation in Tab navigation (0.23)

TabIndex/tabIndex defaults to 0. Set -1 to skip the component during forward and reverse Tab traversal. Only -1 and 0 are accepted; positive indices and other negative values throw. This deliberately limited cross-platform contract does not reproduce every integer value of Telerik Chip.TabIndex. Use the application's layout/traversal policy to establish logical order instead of positive indices.

For a standalone Chip, the setting applies to both its main action and removal action. Static labels and disabled actions never acquire a Tab stop. For ChipList, 0 retains one remembered enabled entry; -1 excludes the entire collection from Tab traversal. The list container remains a programmatic fallback, not an additional Tab stop. Individual items inside a list do not expose independent traversal indices.

Exclusion does not disable the control: mouse/touch, accessibility activation, application focus, arrow navigation and removal continue to work. A focused item is not blurred when the setting changes. FocusAsync()/NgChipListController.focus() can still enter a skipped list, and Tab then leaves it. Returning the setting to 0 restores its remembered enabled entry. Selection and collection state remain parent-owned. Provide another accessible way to enter a list when excluding it; the demo includes a Focus directional topics button.
"""
D['NgChipList']['notes'] += """

### Space between tags (0.23)

Gap/gap accepts sm (4), md (8, default) and lg (12). Blazor uses CSS pixels; Flutter uses logical pixels. The preset applies to both horizontal spacing and the distance between wrapped rows. It does not alter chip padding, font size, focus-outline padding or data order. Invalid strings throw. These are Nextgen spacing tokens; exact Telerik theme pixel matching is not claimed.

Change the preset at runtime without rebuilding records. The Reading direction demo combines a gap selector, RTL switching, skipped Tab traversal and explicit focus. Flutter focus frames add their existing internal padding around each chip, so the visible border-to-border distance is not necessarily identical to Blazor even with equal spacing tokens. Use the controls at narrow widths to assess wrapping with your labels.
"""
D['NgChipList']['blazor'] = D['NgChipList']['blazor'].replace('<NgChipList Id=', '<NgChipList Gap="lg" TabIndex="0" Id=')
D['NgChipList']['dart'] = D['NgChipList']['dart'].replace("NgChipList(semanticIdentifier:", "NgChipList(gap: 'lg', tabIndex: 0, semanticIdentifier:")
D['NgChip']['blazor'] = D['NgChip']['blazor'].replace('<NgChip Id="build-status"', '<NgChip TabIndex="0" Id="build-status"')
D['NgChip']['dart'] = D['NgChip']['dart'].replace("NgChip(semanticIdentifier: 'build-status'", "NgChip(tabIndex: 0, semanticIdentifier: 'build-status'")

# 0.24: selection-only listbox semantics without hiding removal actions.
D['NgChipList']['notes'] = D['NgChipList']['notes'].replace('Blazor still exposes a group of pressed buttons, Flutter its native chip semantics.', 'Blazor uses listbox/options for selection-only lists since 0.24 and a group of pressed buttons for removable lists; Flutter retains native chip semantics.').replace('TabIndex supports -1 and 0 since 0.23; listbox/option roles remain open.', 'TabIndex supports -1 and 0 since 0.23; selection-only Blazor listbox semantics are available since 0.24.')
D['NgChipList']['notes'] += """

### Selection semantics and removal (0.24)

Blazor automatically exposes role=listbox when Selectable is true and no OnRemove callback is supplied. Each main action becomes role=option with aria-selected=true/false instead of aria-pressed. The list declares horizontal orientation; Multiple=true adds aria-multiselectable=true. Single selection omits that attribute. Label or AriaLabelledBy names the list and AriaDescribedBy links guidance. Disabled options remain visible to accessibility tools but are skipped by keyboard navigation.

Arrow keys move focus without changing selection. Enter/Space requests selection through ValueChanged; the parent must assign the new value. One remembered Tab entry initially prefers an enabled selected option. Home/End, RTL, TabIndex and FocusAsync keep their existing behavior. This release does not implement type-ahead, range selection or screen-reader certification.

Supplying OnRemove switches the entire list to role=group, even when CanRemove currently rejects every item. Main actions then expose pressed state and removal remains a separately named button. Removing the callback restores listbox semantics without resetting selected IDs or focus. Selectable=false also uses group semantics. ItemTemplate and LeadingTemplate must remain display-only: do not insert links, buttons or inputs into an option. Standalone NgChip retains its button contract.

This boundary follows the WAI-ARIA listbox interaction model, which does not support interactive descendants inside an option. See [W3C listbox guidance](https://www.w3.org/WAI/ARIA/apg/patterns/listbox/). It deliberately leaves removable-list parity open instead of concealing removal actions from accessibility tools.

Flutter keeps Material chip selection semantics (checkbox/checked in the verified Web accessibility tree). The installed SDK does not provide listbox/option SemanticsRole values. Do not depend on equal DOM roles across frameworks or describe this release as full Telerik accessibility parity.

To try the selection-only contract, omit OnRemove/onRemove from the compiled example; keep ValueChanged/onChanged and the state assignment. The Blazor demo's Selection semantics section switches Multiple and removal at runtime so you can compare the exported roles while preserving state.
"""

D['NgChipList']['notes'] = D['NgChipList']['notes'].replace('Those roles, public accessibility hooks and screen-reader validation remain explicit gaps in the parity matrix.', 'Remaining role differences and screen-reader validation are tracked in the parity matrix; public identity, naming and help hooks are available since 0.22.')
D['NgChipList']['blazor'] = '<h2>Selection-only listbox</h2>\n<NgChipList Label="Selection-only business topics" Items="data.Items" @bind-Value="selected" Multiple />\n' + D['NgChipList']['blazor']

# 0.25: accessible names independent from visible chip text.
D['NgChip']['notes'] += """

### Accessible name versus visible text (0.25)

AriaLabel (Blazor) and semanticLabel (Flutter) optionally replace the main chip's accessible name. Null uses Label/label, preserving existing applications. A supplied name must be nonblank; visible Label/label remains required and retains its 120-character limit. The override does not change visible text, templates, selection, click handling, disabled state or Tab traversal.

Use a meaningful name that includes the visible wording: for a visible CI chip, use CI — Continuous integration. This helps people using speech input identify the same control. Avoid using an unrelated name to hide what a control actually does. For longer instructions use AriaDescribedBy/semanticHint instead of overloading the name. Resolve translations in the application and rebuild normally when they change.

Blazor AriaLabelledBy takes precedence over AriaLabel when it references an existing naming element; AriaLabel then takes precedence over Label. Flutter semanticLabel is its native semantics override, not a DOM aria-labelledby API. Both static statuses and interactive chips support the override. A static Blazor chip with an explicit accessible name exposes a non-focusable group for that name.

The remove action is independent: its default stays Remove {visible label}, and RemoveLabel/removeLabel can override it separately. The main accessible name never changes removal permissions or callbacks. ItemTemplate and ChildContent remain display-only; their text does not replace the explicit accessible name.

The demo's Visible text and accessible name section changes CI's full name at runtime while keeping selected state. No screen-reader certification is implied. ChipList still uses each NgOption label for its main item name; this release adds the override to standalone NgChip only.
"""
D['NgChip']['notes'] = D['NgChip']['notes'].replace('The accessible name remains Label/label', 'The accessible name defaults to Label/label')
D['NgChip']['blazor'] = D['NgChip']['blazor'].replace('Id="build-status"', 'Id="build-status" AriaLabel="Build succeeded — Open build activity"')
D['NgChip']['dart'] = D['NgChip']['dart'].replace("semanticIdentifier: 'build-status'", "semanticIdentifier: 'build-status', semanticLabel: 'Build succeeded — Open build activity'")

D['NgChip']['notes'] = D['NgChip']['notes'].replace('it supplies the accessible name regardless of the visual template.', 'it supplies the default accessible name regardless of the visual template; AriaLabel/semanticLabel can override the main name since 0.25.')
