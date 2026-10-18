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
