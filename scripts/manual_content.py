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
                          '@bind-SelectedIds="selected" CanSelect="r=>r.Count < 100" PageSizes="new[]{5,10,20}"/>\n'
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
                        '  canSelect: (r) => r.count < 100, pageSizes: const [5, 10, 20],\n'
                        '  onSelectionChanged: (v) => setState(() => selected = v),\n'
                        "  columns: [NgDataColumn('name','Name',(r) => r.name),\n"
                        "    NgDataColumn('count','Quantity',(r) => r.count)]);",
                'notes': 'NgDataColumn<T> supplies a stable key, title and Value/value accessor. Return '
                         'typed values for sorting; Format/format changes display only. Template/cellBuilder '
                         'customizes a cell. RowId and column keys must be nonempty and unique; at least one column is required. '
                         'CanSelect/canSelect protects rows from row and page selection without deleting existing selected IDs. '
                         'SelectionReadOnly/selectionReadOnly freezes selection while search, sort and paging remain available. '
                         'Page selection affects only eligible visible rows and preserves hidden or protected selections. '
                         'Selection is controlled: accept the callback and pass the new set back; the original set is never mutated. '
                         'PageSizes/pageSizes configures the pager; positive distinct sizes are sorted and the current size is retained. '
                         'EmptyTemplate/emptyBuilder replaces the empty-result message. Save selection callbacks '
                         'and replace Items/items after edits so the grid recalculates. Toolbar and row '
                         'actions allow the application to own editing and persistence. This local grid does '
                         'not implement server data binding, virtualization, column grouping or Excel '
                         'export; see [data workspace](../data-workspace.md).'},
 'NgTreeView': {'title': 'Tree view',
 'use': 'Browse and select hierarchical records.',
 'blazor': '<NgCheckBox Label="Selection read-only" @bind-Value="selectionReadOnly"/>\n'
           '<NgCheckBox Label="Expansion read-only" @bind-Value="expansionReadOnly"/>\n'
           '<NgTreeView TItem="string" Items="nodes" Text="s=>s" @bind-ExpandedIds="expanded" '
           '@bind-SelectedId="selected" SelectionReadOnly="selectionReadOnly" '
           'ExpansionReadOnly="expansionReadOnly" EmptyText="No teams found."><ItemTemplate '
           'Context="item"><strong>@item</strong><span> · team</span></ItemTemplate></NgTreeView>\n'
           '<p>Selected team: @(selected??"none")</p>\n'
           '@code { private bool selectionReadOnly,expansionReadOnly; private string? selected; '
           'private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] '
           'nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; }',
 'dart': 'bool selectionReadOnly = false, expansionReadOnly = false;\n'
         "Set<String> expanded = {'root'}; String? selected;\n"
         'Widget build(BuildContext context) => Column(crossAxisAlignment: '
         'CrossAxisAlignment.stretch, children: [\n'
         "  NgCheckBox(label: 'Selection read-only', value: selectionReadOnly, onChanged: (v) => "
         'setState(() => selectionReadOnly = v)),\n'
         "  NgCheckBox(label: 'Expansion read-only', value: expansionReadOnly, onChanged: (v) => "
         'setState(() => expansionReadOnly = v)),\n'
         '  NgTreeView<String>(\n'
         '  selectionReadOnly: selectionReadOnly, expansionReadOnly: expansionReadOnly,\n'
         "  emptyText: 'No teams found.',\n"
         "  items: const [NgTreeNode('root','Projects',children: "
         "[NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],\n"
         '  text: (s) => s,\n'
         "  itemBuilder: (context, s) => Text('$s · team', style: const TextStyle(fontWeight: "
         'FontWeight.bold)),\n'
         '  expandedIds: expanded, selectedId: selected,\n'
         '  onExpandedChanged: (v) => setState(() => expanded = v),\n'
         '  onSelected: (v) => setState(() => selected = v)),\n'
         '  Text(\'Selected team: ${selected ?? "none"}\'),\n'
         ']);',
 'notes': 'NgTreeNode<T> contains a stable unique ID, item, children and disabled flag. The graph '
          'must be acyclic. ExpandedIds and SelectedId are controlled: save callbacks and pass '
          'updated collections back. Replacing the tree should also remove obsolete IDs from '
          'parent selection/expansion. Disabled nodes cannot be selected. Lazy server loading, '
          'drag/drop and virtualization are not implemented. SelectionReadOnly/selectionReadOnly '
          'blocks selection but permits navigation and expansion. '
          'ExpansionReadOnly/expansionReadOnly freezes expansion but permits selection. Search '
          'still reveals matching descendant paths without changing expanded IDs; clearing search '
          'restores caller state. Whitespace-only search is inactive. Disabled nodes and stale '
          'callbacks cannot change state. EmptyText/emptyText and EmptyTemplate/emptyBuilder '
          'customize no-results content. IDs must be nonempty. Parent updates can replace or clear '
          'state even in read-only mode. Missing selected/expanded IDs are retained in caller '
          'state, not automatically pruned. ItemTemplate/itemBuilder is decorative: Text/text '
          'supplies the accessible name and search text. Do not place interactive controls in this '
          'template. ArrowRight enters only an enabled immediate child; leaves do not move focus '
          'to siblings. Full roving-tabindex/focus recovery, type-ahead, checkboxes and '
          'multi-selection remain open.'},
 'NgTreeList': {'title': 'Tree list',
 'use': 'Combine hierarchical rows with typed columns.',
 'blazor': '<NgCheckBox Label="Selection read-only" @bind-Value="selectionReadOnly"/>\n'
           '<NgCheckBox Label="Expansion read-only" @bind-Value="expansionReadOnly"/>\n'
           '<NgTreeList TItem="string" Items="nodes" Columns="columns" '
           '@bind-ExpandedIds="expanded" @bind-SelectedId="selected" '
           'SelectionReadOnly="selectionReadOnly" ExpansionReadOnly="expansionReadOnly" '
           'EmptyText="No teams found."/>\n'
           '<p>Selected team: @(selected??"none")</p>\n'
           '@code { private bool selectionReadOnly,expansionReadOnly; private string? selected; '
           'private HashSet<string> expanded=["root"]; private NgTreeNode<string>[] '
           'nodes=[new("root","Projects",[new("a","Design"),new("b","Engineering")])]; private '
           'NgDataColumn<string>[] '
           'columns=[new("name","Name",s=>s,Template:s=>@<strong>@s</strong>)]; }',
 'dart': 'bool selectionReadOnly = false, expansionReadOnly = false;\n'
         "Set<String> expanded = {'root'}; String? selected;\n"
         'Widget build(BuildContext context) => Column(crossAxisAlignment: '
         'CrossAxisAlignment.stretch, children: [\n'
         "  NgCheckBox(label: 'Selection read-only', value: selectionReadOnly, onChanged: (v) => "
         'setState(() => selectionReadOnly = v)),\n'
         "  NgCheckBox(label: 'Expansion read-only', value: expansionReadOnly, onChanged: (v) => "
         'setState(() => expansionReadOnly = v)),\n'
         '  NgTreeList<String>(\n'
         '  selectionReadOnly: selectionReadOnly, expansionReadOnly: expansionReadOnly,\n'
         "  emptyText: 'No teams found.',\n"
         "  items: const [NgTreeNode('root','Projects',children: "
         "[NgTreeNode('a','Design'),NgTreeNode('b','Engineering')])],\n"
         "  columns: [NgDataColumn('name','Name',(s) => s, cellBuilder: (context,s) => Text(s, "
         'style: const TextStyle(fontWeight: FontWeight.bold)))],\n'
         '  expandedIds: expanded, selectedId: selected,\n'
         '  onExpandedChanged: (v) => setState(() => expanded = v),\n'
         '  onSelected: (v) => setState(() => selected = v)),\n'
         '  Text(\'Selected team: ${selected ?? "none"}\'),\n'
         ']);',
 'notes': 'Use NgTreeNode<T> for hierarchy and NgDataColumn<T> for cells. IDs must be unique '
          'across the whole tree. Persist expanded/selected IDs through callbacks; replace '
          'collections after data changes. Column accessors return underlying values, while '
          'format/cell templates define presentation. Application code owns edits and persistence. '
          'See [data workspace](../data-workspace.md) for sorting/filtering scope and omitted '
          'server/virtualization features. SelectionReadOnly/selectionReadOnly blocks selection '
          'but permits navigation and expansion. ExpansionReadOnly/expansionReadOnly freezes '
          'expansion but permits selection. Search still reveals matching descendant paths without '
          'changing expanded IDs; clearing search restores caller state. Whitespace-only search is '
          'inactive. Disabled nodes and stale callbacks cannot change state. EmptyText/emptyText '
          'and EmptyTemplate/emptyBuilder customize no-results content. IDs must be nonempty. '
          'Parent updates can replace or clear state even in read-only mode. Missing '
          'selected/expanded IDs are retained in caller state, not automatically pruned. '
          'First-column Template/cellBuilder now works inside the select control; keep it '
          'decorative. The formatted column text supplies the accessible name. Columns require '
          'unique nonempty keys and at least one entry. TreeList has table/button keyboard '
          'semantics, not a treegrid keyboard model.'},
 'NgChart': {'title': 'Chart',
 'use': 'Visualize local series as column, bar, line, area, pie or donut charts.',
 'blazor': '<div class="row"><NgCheckBox Label="Selection read-only" '
           '@bind-Value="readOnly"/><NgCheckBox Label="Legend read-only" '
           '@bind-Value="legendReadOnly"/><NgCheckBox Label="Accept legend changes" '
           '@bind-Value="accept"/></div>\n'
           '<NgButton OnClick="()=>hidden=[]">Show all series</NgButton><NgButton '
           'OnClick="()=>revised=!revised">Update values</NgButton><NgButton '
           'OnClick="()=>invalid=!invalid">Toggle invalid data</NgButton>\n'
           '<NgChart Title="Weekly orders" Kind="NgChartKind.Column" Categories="categories" '
           'Series="Series" HiddenSeries="hidden" HiddenSeriesChanged="ChangeHidden" '
           'SelectionReadOnly="readOnly" LegendReadOnly="legendReadOnly" PointLabel="Label" '
           'EmptyText="All series hidden." OnPointSelected="p=>last=Label(p)"/>\n'
           '<p>Last callback: @last</p>\n'
           '@code {\n'
           ' private bool readOnly,legendReadOnly,revised,invalid; private bool accept=true;\n'
           ' private HashSet<int> hidden=[]; private string last="none";\n'
           ' private string[] categories=["Mon","Tue","Wed"];\n'
           ' private NgChartSeries[] '
           'Series=>invalid?[new("Orders",[1])]:[new("Orders",[revised?40:10,20,25]),new("Target",[15,25,30])];\n'
           ' private void ChangeHidden(HashSet<int> value){if(accept)hidden=value;}\n'
           ' private static string Label(NgChartSelection p)=>$"{p.Series} / {p.Category}: '
           '{p.Value:0} orders";\n'
           '}',
 'dart': 'bool readOnly=false, legendReadOnly=false, revised=false, invalid=false, accept=true;\n'
         "Set<int> hidden={}; String last='none';\n"
         "String pointText(NgChartSelection p) => '${p.series} / ${p.category}: "
         "${p.value.toStringAsFixed(0)} orders';\n"
         'Widget build(BuildContext context) => Column(crossAxisAlignment: '
         'CrossAxisAlignment.stretch, children: [\n'
         "  NgCheckBox(label: 'Selection read-only', value: readOnly, onChanged: "
         '(v)=>setState(()=>readOnly=v)),\n'
         "  NgCheckBox(label: 'Legend read-only', value: legendReadOnly, onChanged: "
         '(v)=>setState(()=>legendReadOnly=v)),\n'
         "  NgCheckBox(label: 'Accept legend changes', value: accept, onChanged: "
         '(v)=>setState(()=>accept=v)),\n'
         '  Wrap(spacing: 8, runSpacing: 8, children: [\n'
         "    NgButton(onPressed: ()=>setState(()=>hidden={}), child: const Text('Show all "
         "series')),\n"
         "    NgButton(onPressed: ()=>setState(()=>revised=!revised), child: const Text('Update "
         "values')),\n"
         "    NgButton(onPressed: ()=>setState(()=>invalid=!invalid), child: const Text('Toggle "
         "invalid data')),\n"
         '  ]),\n'
         "  NgChart(title: 'Weekly orders', categories: const ['Mon','Tue','Wed'],\n"
         "    series: invalid ? const [NgChartSeries('Orders',[1])] : "
         "[NgChartSeries('Orders',[revised?40:10,20,25]), const "
         "NgChartSeries('Target',[15,25,30])],\n"
         '    hiddenSeries: hidden, onHiddenSeriesChanged: '
         '(v){if(accept)setState(()=>hidden=v);},\n'
         '    selectionReadOnly: readOnly, legendReadOnly: legendReadOnly, pointLabel: pointText,\n'
         "    emptyText: 'All series hidden.', onPointSelected: "
         '(p)=>setState(()=>last=pointText(p))),\n'
         "  Text('Last callback: $last'),\n"
         ']);',
 'notes': 'Categories define the shared domain; every series must have the same number of nullable '
          'numeric values. Null breaks a line instead of becoming zero. Point selection returns '
          'NgChartSelection with zero-based series/point indices, their names, the number and a '
          'ready-to-use label. The application chooses what to do with a point. Keep units '
          'explicit. See [analytics and scheduling](../analytics-and-schedule.md) for '
          'mode-specific constraints; advanced axes, export, remote aggregation and broad '
          'chart-type parity are not implemented. HiddenSeries/hiddenSeries is optional: null '
          'keeps internal legend state, a set enables controlled visibility. '
          'HiddenSeriesChanged/onHiddenSeriesChanged proposes a fresh set; the parent must accept '
          'it. A controlled set without a callback is noninteractive. Unknown indices are ignored '
          'by drawing and retained in controlled proposals; the parent owns pruning and '
          'reordering. Series identity is its zero-based index. Keep the same ownership mode for '
          'the lifetime of a chart; returning to internal mode resumes its prior internal state. '
          'LegendReadOnly/legendReadOnly freezes user legend changes, while '
          'SelectionReadOnly/selectionReadOnly blocks point actions without hiding their data or '
          'tooltips. Programmatic visibility updates still work. PointLabel/pointLabel returns '
          'plain text for tooltips, point actions, accessible names and selected-point status; it '
          'does not change numeric values or axes. EmptyText/emptyText customizes the empty chart '
          'message. Selection survives equivalent data replacement, but clears when the selected '
          'point is hidden, removed, renamed or changes value, or when data becomes invalid. '
          'Invalid data recovery does not restore stale selection. Captured point callbacks are '
          'rejected if they no longer match a visible current point. This is chart-owned '
          'selection, not a controlled selection API.'},
 'NgLinearGauge': {'title': 'Linear gauge',
                   'use': 'Display a value within a numeric range.',
                   'blazor': '<div class="toolbar">\n'
                             '<NgButton OnClick="()=>value=42.5">Normal</NgButton>\n'
                             '<NgButton OnClick="()=>value=72.5">Elevated</NgButton>\n'
                             '<NgButton OnClick="()=>value=95">High</NgButton>\n'
                             '<NgButton OnClick="()=>value=125">Above maximum</NgButton>\n'
                             '<NgButton OnClick="()=>value=-10">Below minimum</NgButton>\n'
                             '<NgButton OnClick="()=>showRanges=!showRanges">Toggle '
                             'ranges</NgButton>\n'
                             '</div>\n'
                             '<NgLinearGauge Label="Load" Value="value" '
                             'Ranges="@(showRanges?ranges:[])" ValueFormatter="Format"/>\n'
                             '@code {\n'
                             ' private double value=72.5;\n'
                             ' private bool showRanges=true;\n'
                             ' private string Format(double '
                             'v)=>v.ToString("F1",System.Globalization.CultureInfo.InvariantCulture);\n'
                             ' private NgGaugeRange[] '
                             'ranges=[new(0,60,"#187444","Normal"),new(60,85,"#b66d16","Elevated"),new(85,100,"#b42318","High")];\n'
                             '}',
                   'dart': 'double value = 72.5;\n'
                           'bool showRanges = true;\n'
                           "final ranges = const [NgGaugeRange(0,60,'#187444','Normal'), "
                           "NgGaugeRange(60,85,'#b66d16','Elevated'), "
                           "NgGaugeRange(85,100,'#b42318','High')];\n"
                           'Widget build(BuildContext context) => Column(crossAxisAlignment: '
                           'CrossAxisAlignment.stretch, children: [\n'
                           ' Wrap(spacing: 8, runSpacing: 8, children: [\n'
                           "  for (final entry in {'Normal':42.5, 'Elevated':72.5, 'High':95.0, "
                           "'Above maximum':125.0, 'Below minimum':-10.0}.entries)\n"
                           '   NgButton(onPressed:()=>setState(()=>value=entry.value), '
                           'child:Text(entry.key)),\n'
                           '  NgButton(onPressed:()=>setState(()=>showRanges=!showRanges), '
                           "child:const Text('Toggle ranges')),\n"
                           ' ]),\n'
                           ' const SizedBox(height:16),\n'
                           " NgLinearGauge(label:'Load',value:value,ranges:showRanges?ranges:const "
                           '[],valueFormatter:(v)=>v.toStringAsFixed(1)),\n'
                           ']);',
                   'notes': 'Min must be less than Max; all numbers must be finite. Even finite '
                            'bounds whose difference overflows are supported. Drawing clamps '
                            'outside values; the displayed original value and Above maximum/Below '
                            'minimum status preserve the supplied reading. Ranges/ranges accepts '
                            'NgGaugeRange(From, To, Color, Label), lowercase fields in Flutter. '
                            'Colors must be six-digit hex (#RRGGBB), labels nonblank, ranges '
                            'inside the scale with From < To and no overlap. Input order is '
                            'immaterial; validation sorts a copy. Gaps are allowed and use the '
                            'theme primary color. Shared endpoints belong to the next range; Max '
                            'belongs to the range ending at Max. Active color uses the clamped '
                            'value. Stripes/arcs and a text legend show all ranges. '
                            'ValueFormatter/valueFormatter formats current value, bounds and '
                            'legend as plain text; Unit is appended only to the current value. '
                            'Defaults preserve six significant digits, including fractional '
                            'values. Replace lists when updating Flutter inputs. This is a '
                            'read-only single-scale indicator; pointers, ticks, animation and '
                            'export are not implemented.'},
 'NgArcGauge': {'title': 'Arc gauge',
                'use': 'Display a value within a numeric range.',
                'blazor': '<div class="toolbar">\n'
                          '<NgButton OnClick="()=>value=42.5">Normal</NgButton>\n'
                          '<NgButton OnClick="()=>value=72.5">Elevated</NgButton>\n'
                          '<NgButton OnClick="()=>value=95">High</NgButton>\n'
                          '<NgButton OnClick="()=>value=125">Above maximum</NgButton>\n'
                          '<NgButton OnClick="()=>value=-10">Below minimum</NgButton>\n'
                          '<NgButton OnClick="()=>showRanges=!showRanges">Toggle '
                          'ranges</NgButton>\n'
                          '</div>\n'
                          '<NgArcGauge Label="Load" Value="value" Ranges="@(showRanges?ranges:[])" '
                          'ValueFormatter="Format"/>\n'
                          '@code {\n'
                          ' private double value=72.5;\n'
                          ' private bool showRanges=true;\n'
                          ' private string Format(double '
                          'v)=>v.ToString("F1",System.Globalization.CultureInfo.InvariantCulture);\n'
                          ' private NgGaugeRange[] '
                          'ranges=[new(0,60,"#187444","Normal"),new(60,85,"#b66d16","Elevated"),new(85,100,"#b42318","High")];\n'
                          '}',
                'dart': 'double value = 72.5;\n'
                        'bool showRanges = true;\n'
                        "final ranges = const [NgGaugeRange(0,60,'#187444','Normal'), "
                        "NgGaugeRange(60,85,'#b66d16','Elevated'), "
                        "NgGaugeRange(85,100,'#b42318','High')];\n"
                        'Widget build(BuildContext context) => Column(crossAxisAlignment: '
                        'CrossAxisAlignment.stretch, children: [\n'
                        ' Wrap(spacing: 8, runSpacing: 8, children: [\n'
                        "  for (final entry in {'Normal':42.5, 'Elevated':72.5, 'High':95.0, "
                        "'Above maximum':125.0, 'Below minimum':-10.0}.entries)\n"
                        '   NgButton(onPressed:()=>setState(()=>value=entry.value), '
                        'child:Text(entry.key)),\n'
                        '  NgButton(onPressed:()=>setState(()=>showRanges=!showRanges), '
                        "child:const Text('Toggle ranges')),\n"
                        ' ]),\n'
                        ' const SizedBox(height:16),\n'
                        " NgArcGauge(label:'Load',value:value,ranges:showRanges?ranges:const "
                        '[],valueFormatter:(v)=>v.toStringAsFixed(1)),\n'
                        ']);',
                'notes': 'Min must be less than Max; all numbers must be finite. Even finite '
                         'bounds whose difference overflows are supported. Drawing clamps outside '
                         'values; the displayed original value and Above maximum/Below minimum '
                         'status preserve the supplied reading. Ranges/ranges accepts '
                         'NgGaugeRange(From, To, Color, Label), lowercase fields in Flutter. '
                         'Colors must be six-digit hex (#RRGGBB), labels nonblank, ranges inside '
                         'the scale with From < To and no overlap. Input order is immaterial; '
                         'validation sorts a copy. Gaps are allowed and use the theme primary '
                         'color. Shared endpoints belong to the next range; Max belongs to the '
                         'range ending at Max. Active color uses the clamped value. Stripes/arcs '
                         'and a text legend show all ranges. ValueFormatter/valueFormatter formats '
                         'current value, bounds and legend as plain text; Unit is appended only to '
                         'the current value. Defaults preserve six significant digits, including '
                         'fractional values. Replace lists when updating Flutter inputs. This is a '
                         'read-only single-scale indicator; pointers, ticks, animation and export '
                         'are not implemented.'},
 'NgScheduler': {'title': 'Day and week scheduler',
                 'use': 'Browse daily or weekly agendas with controlled navigation and guarded '
                        'edit requests.',
                 'blazor': '<div class="toolbar">\n'
                           '<NgButton OnClick="()=>readOnly=!readOnly">Toggle editing '
                           'lock</NgButton>\n'
                           '<NgButton OnClick="()=>navigationReadOnly=!navigationReadOnly">Toggle '
                           'navigation lock</NgButton>\n'
                           '<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>\n'
                           '<NgButton OnClick="()=>firstDay=firstDay==1?7:1">Toggle week '
                           'start</NgButton>\n'
                           '<NgButton OnClick="()=>empty=!empty">Toggle events</NgButton>\n'
                           '<NgButton OnClick="Reset">Reset date</NgButton>\n'
                           '</div>\n'
                           '<p>Editing @(readOnly?"locked":"enabled") · Navigation '
                           '@(navigationReadOnly?"locked":"enabled") · Proposals '
                           '@(accept?"accepted":"rejected") · Week starts '
                           '@(firstDay==1?"Monday":"Sunday")</p>\n'
                           '<NgScheduler Date="date" DateChanged="d=>{if(accept)date=d;}" '
                           'View="view" ViewChanged="v=>{if(accept)view=v;}" '
                           'FirstDayOfWeek="firstDay" ReadOnly="readOnly" '
                           'NavigationReadOnly="navigationReadOnly" Items="@(empty?[]:events)" '
                           'EventLabel="EventText" EmptyText="No shifts planned" OnCreate="Create" '
                           'OnEdit="Edit"/>\n'
                           '<p role="status">Last action: @message</p>\n'
                           '@code {\n'
                           ' private DateTime date=new(2026,10,19);\n'
                           ' private NgScheduleView view=NgScheduleView.Week;\n'
                           ' private bool readOnly,navigationReadOnly,empty,accept=true;\n'
                           ' private int firstDay=1;\n'
                           ' private string message="none";\n'
                           ' private NgScheduleEvent[] '
                           'events=[new("review","Review",new(2026,10,19,10,0,0),new(2026,10,19,11,0,0)),new("night","Overnight",new(2026,10,19,23,0,0),new(2026,10,20,1,0,0))];\n'
                           ' private string EventText(NgScheduleEvent e)=>$"Shift: {e.Title}";\n'
                           ' private void Create(DateTime d)=>message=$"Create: {d:yyyy-MM-dd}";\n'
                           ' private void Edit(NgScheduleEvent e)=>message=$"Edit: {e.Title}";\n'
                           ' private void Reset(){date=new(2026,10,19);view=NgScheduleView.Week;}\n'
                           '}',
                 'dart': 'DateTime date=DateTime(2026,10,19);\n'
                         'NgScheduleView view=NgScheduleView.week;\n'
                         'bool readOnly=false,navigationReadOnly=false,empty=false,accept=true;\n'
                         'int firstDay=1;\n'
                         "String message='none';\n"
                         'final '
                         "events=[NgScheduleEvent('review','Review',DateTime(2026,10,19,10),DateTime(2026,10,19,11)),NgScheduleEvent('night','Overnight',DateTime(2026,10,19,23),DateTime(2026,10,20,1))];\n"
                         'Widget build(BuildContext '
                         'context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\n'
                         ' Wrap(spacing:8,runSpacing:8,children:[\n'
                         '  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const '
                         "Text('Toggle editing lock')),\n"
                         '  '
                         'NgButton(onPressed:()=>setState(()=>navigationReadOnly=!navigationReadOnly),child:const '
                         "Text('Toggle navigation lock')),\n"
                         '  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const '
                         "Text('Toggle acceptance')),\n"
                         '  '
                         'NgButton(onPressed:()=>setState(()=>firstDay=firstDay==1?7:1),child:const '
                         "Text('Toggle week start')),\n"
                         '  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const '
                         "Text('Toggle events')),\n"
                         '  '
                         'NgButton(onPressed:()=>setState((){date=DateTime(2026,10,19);view=NgScheduleView.week;}),child:const '
                         "Text('Reset date')),\n"
                         ' ]),\n'
                         ' Text(\'Editing ${readOnly?"locked":"enabled"} · Navigation '
                         '${navigationReadOnly?"locked":"enabled"} · Proposals '
                         '${accept?"accepted":"rejected"} · Week starts '
                         '${firstDay==1?"Monday":"Sunday"}\'),\n'
                         ' '
                         'NgScheduler(date:date,view:view,firstDayOfWeek:firstDay,readOnly:readOnly,navigationReadOnly:navigationReadOnly,items:empty?const '
                         '[]:events,\n'
                         '  '
                         'onDateChanged:(d){if(accept)setState(()=>date=d);},onViewChanged:(v){if(accept)setState(()=>view=v);},\n'
                         "  eventLabel:(e)=>'Shift: ${e.title}',emptyText:'No shifts planned',\n"
                         "  onCreate:(d)=>setState(()=>message='Create: "
                         "${NgScheduler.dayText(d)}'),onEdit:(e)=>setState(()=>message='Edit: "
                         "${e.title}')),\n"
                         " Text('Last action: $message'),\n"
                         ']);',
                 'notes': 'Date/date and View/view are controlled; accept '
                          'DateChanged/onDateChanged and ViewChanged/onViewChanged to apply '
                          'proposals. Week is the default, Day shows one agenda. Previous/Next '
                          'move by seven or one calendar days; Today proposes local midnight. A '
                          'rejected proposal keeps the current display. '
                          'FirstDayOfWeek/firstDayOfWeek uses ISO 1–7 (Monday–Sunday), default 1, '
                          'and only changes weekly alignment. All displayed days must fall in '
                          'years 2–9998; invalid configuration is rejected and navigation across '
                          'the boundary is disabled. ReadOnly/readOnly disables create/edit; '
                          'NavigationReadOnly/navigationReadOnly independently disables date/view '
                          'actions. Programmatic date/view updates still work. Missing callbacks '
                          'disable the related actions. Stale callbacks after date/view changes, '
                          'editing locks, event removal/change or disposal cannot edit old data. '
                          'NgScheduleEvent requires a unique nonblank ID, nonblank title and End > '
                          'Start. Events intersect days using [Start, End), so an event ending at '
                          'midnight is excluded from the next day; overnight events appear on '
                          'every intersected day. EventLabel/eventLabel formats plain text without '
                          'changing callback data; EmptyText/emptyText replaces the empty-day '
                          'message. Replace input lists instead of mutating them. Times are local '
                          'wall-clock values; callers normalize zones before passing data. The '
                          'application owns the editor and persistence. This is an agenda layout, '
                          'not a time-slot grid; month/year views, recurrence, resources, '
                          'drag/resize and timezone conversion remain open.'},
 'NgSpreadsheet': {'title': 'Spreadsheet',
                   'use': 'Edit a small local worksheet with formulas and undo/redo.',
                   'blazor': '<div class="toolbar">\n'
                             '<NgButton OnClick="()=>protect=!protect">Toggle '
                             'protection</NgButton>\n'
                             '<NgButton OnClick="()=>lockA1=!lockA1">Toggle A1 lock</NgButton>\n'
                             '<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>\n'
                             '<NgButton OnClick="()=>readOnly=!readOnly">Toggle '
                             'read-only</NgButton>\n'
                             '<NgButton OnClick="()=>sheet=Initial()">Reset sheet</NgButton>\n'
                             '<NgButton OnClick="()=>sheet=new(1,1)">Shrink sheet</NgButton>\n'
                             '</div>\n'
                             '<p>Protection @(protect?"enabled":"disabled") · A1 '
                             '@(lockA1?"locked":"editable") · Changes '
                             '@(accept?"accepted":"rejected")</p>\n'
                             '<NgSpreadsheet Value="sheet" ValueChanged="Changed" '
                             'CanEdit="Editable" ReadOnly="readOnly"/>\n'
                             '<p>Accepted A1: @sheet.Raw("A1") · Proposals: @proposals</p>\n'
                             '@code {\n'
                             ' private NgSheet sheet=Initial();\n'
                             ' private bool protect=true,lockA1,readOnly,accept=true;\n'
                             ' private int proposals;\n'
                             ' private bool Editable(string '
                             'a)=>(!protect||!a.StartsWith("C"))&&(!lockA1||a!="A1");\n'
                             ' private void Changed(NgSheet '
                             'next){proposals++;if(accept)sheet=next;}\n'
                             ' private static NgSheet Initial()=>new(4,4,new '
                             'Dictionary<string,string>{{"A1","10"},{"B1","20"},{"C1","=SUM(A1:B1)"}});\n'
                             '}',
                   'dart': 'NgSheet sheet=initial();\n'
                           'bool protect=true,lockA1=false,readOnly=false,accept=true;\n'
                           'int proposals=0;\n'
                           'static NgSheet '
                           "initial()=>NgSheet(rows:4,columns:4,cells:{'A1':'10','B1':'20','C1':'=SUM(A1:B1)'});\n"
                           'bool editable(String '
                           "a)=>(!protect||!a.startsWith('C'))&&(!lockA1||a!='A1');\n"
                           'Widget build(BuildContext '
                           'context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\n'
                           ' Wrap(spacing:8,runSpacing:8,children:[\n'
                           '  NgButton(onPressed:()=>setState(()=>protect=!protect),child:const '
                           "Text('Toggle protection')),\n"
                           '  NgButton(onPressed:()=>setState(()=>lockA1=!lockA1),child:const '
                           "Text('Toggle A1 lock')),\n"
                           '  NgButton(onPressed:()=>setState(()=>accept=!accept),child:const '
                           "Text('Toggle acceptance')),\n"
                           '  NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const '
                           "Text('Toggle read-only')),\n"
                           '  NgButton(onPressed:()=>setState(()=>sheet=initial()),child:const '
                           "Text('Reset sheet')),\n"
                           '  '
                           'NgButton(onPressed:()=>setState(()=>sheet=NgSheet(rows:1,columns:1)),child:const '
                           "Text('Shrink sheet')),\n"
                           ' ]),\n'
                           ' Text(\'Protection ${protect?"enabled":"disabled"} · A1 '
                           '${lockA1?"locked":"editable"} · Changes '
                           '${accept?"accepted":"rejected"}\'),\n'
                           ' '
                           'NgSpreadsheet(value:sheet,canEdit:editable,readOnly:readOnly,onChanged:(v)=>setState((){proposals++;if(accept)sheet=v;})),\n'
                           ' Text(\'Accepted A1: ${sheet.raw("A1")} · Proposals: $proposals\'),\n'
                           ']);',
                   'notes': 'Value/value is controlled. Apply, paste, Undo and Redo propose an '
                            'immutable NgSheet through ValueChanged/onChanged; display and history '
                            'change only when the parent returns that exact instance on its next '
                            'parameter update. Rejection keeps the accepted sheet, history and '
                            'typed formula draft. A different external replacement clears history '
                            'and reloads the draft; an out-of-bounds selection resets to A1. No-op '
                            'edits produce no callback or history entry. Protection applies to '
                            'user actions; the parent can still replace the whole sheet '
                            'programmatically. Without a callback, editing is disabled. '
                            'ReadOnly/readOnly blocks all changes but permits selection and '
                            'formula inspection. CanEdit/canEdit is a pure predicate receiving '
                            'uppercase addresses such as A1; false protects the cell, displays a '
                            'Protected marker and locks its formula input. Protected cells still '
                            'recalculate when their dependencies change. Paste checks every '
                            'supplied destination, including unchanged values: any protected or '
                            'out-of-bounds destination rejects the entire block. TSV rows may have '
                            'different widths; only supplied cells are targeted. Formulas remain '
                            'literal, without relative-reference adjustment. Undo/Redo keep up to '
                            '50 accepted operations and check current protection for every raw '
                            'cell value they would change. Changing protection never clears '
                            'history; lifting protection re-enables eligible history operations. '
                            'Captured actions cannot modify a replaced sheet or bypass a new lock; '
                            'callbacks after disposal are ignored. NgSheet.Paste/paste also '
                            'accepts an optional canEdit predicate for model-level atomic '
                            'validation; ChangedCells/changedCells compares raw values of '
                            'equal-sized sheets. Limits: 1–100 rows, 1–26 columns and 1,000 '
                            'characters per cell. See [models and formulas](models.md) for formula '
                            'syntax. Single sheet only: no XLSX/CSV, formatting, merges, '
                            'multi-cell selection, clipboard integration or multi-sheet workbook.'},
 'NgPivotGrid': {'title': 'Pivot grid',
                 'use': 'Aggregate records by row and column dimensions.',
                 'blazor': '<div class="toolbar">\n'
                           '<NgButton OnClick="()=>rowTotals=!rowTotals">Toggle row '
                           'totals</NgButton>\n'
                           '<NgButton OnClick="()=>columnTotals=!columnTotals">Toggle column '
                           'totals</NgButton>\n'
                           '<NgButton OnClick="()=>locked=!locked">Toggle selection '
                           'lock</NgButton>\n'
                           '<NgButton OnClick="()=>average=!average">Toggle average</NgButton>\n'
                           '<NgButton OnClick="()=>empty=!empty">Toggle empty data</NgButton>\n'
                           '<NgButton OnClick="()=>records=Data(2)">Update values</NgButton>\n'
                           '</div>\n'
                           '<p>Row totals @(rowTotals?"shown":"hidden") · Column totals '
                           '@(columnTotals?"shown":"hidden") · Selection '
                           '@(locked?"locked":"enabled")</p>\n'
                           '<NgPivotGrid Items="@(empty?[]:records)" '
                           'Aggregate="@(average?NgAggregate.Average:NgAggregate.Sum)" '
                           'ShowRowTotals="rowTotals" ShowColumnTotals="columnTotals" '
                           'SelectionReadOnly="locked" ValueFormatter="Format" RowLabel="RowText" '
                           'ColumnLabel="ColumnText" TotalText="All" EmptyText="No matching '
                           'deliveries" OnCellSelected="Selected"/>\n'
                           '<p role="status">Last drilldown: @message</p>\n'
                           '@code {\n'
                           ' private bool rowTotals=true,columnTotals=true,locked,average,empty;\n'
                           ' private string message="none";\n'
                           ' private NgPivotRecord[] records=Data(1);\n'
                           ' private string Format(double? '
                           'v)=>v.HasValue?v.Value.ToString("F1",System.Globalization.CultureInfo.InvariantCulture)+" '
                           'credits":"No value";\n'
                           ' private string RowText(string v)=>v==""?"Unassigned":"Team "+v;\n'
                           ' private string ColumnText(string v)=>"Period "+v;\n'
                           ' private void Selected(NgPivotSelection '
                           'p)=>message=$"{p.Row??"(total)"} / {p.Column??"(total)"} · '
                           '{p.Records.Count} records · IDs: '
                           '{string.Join(",",p.Records.Select(r=>r.Id))}";\n'
                           ' private static NgPivotRecord[] Data(int factor)=>[new("a",new '
                           'Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},10*factor),new("b",new '
                           'Dictionary<string,string>{{"Team","A"},{"Quarter","Q1"}},30*factor),new("c",new '
                           'Dictionary<string,string>{{"Team","B"},{"Quarter","Q2"}},90*factor),new("d",new '
                           'Dictionary<string,string>{{"Team",""},{"Quarter","Q1"}},null)];\n'
                           '}',
                 'dart': 'bool '
                         'rowTotals=true,columnTotals=true,locked=false,average=false,empty=false;\n'
                         "String message='none';\n"
                         'List<NgPivotRecord> records=data(1);\n'
                         'static List<NgPivotRecord> data(int '
                         "factor)=>[NgPivotRecord('a',{'Team':'A','Quarter':'Q1'},10.0*factor),NgPivotRecord('b',{'Team':'A','Quarter':'Q1'},30.0*factor),NgPivotRecord('c',{'Team':'B','Quarter':'Q2'},90.0*factor),NgPivotRecord('d',{'Team':'','Quarter':'Q1'},null)];\n"
                         'Widget build(BuildContext '
                         'context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\n'
                         ' Wrap(spacing:8,runSpacing:8,children:[\n'
                         '  NgButton(onPressed:()=>setState(()=>rowTotals=!rowTotals),child:const '
                         "Text('Toggle row totals')),\n"
                         '  '
                         'NgButton(onPressed:()=>setState(()=>columnTotals=!columnTotals),child:const '
                         "Text('Toggle column totals')),\n"
                         '  NgButton(onPressed:()=>setState(()=>locked=!locked),child:const '
                         "Text('Toggle selection lock')),\n"
                         '  NgButton(onPressed:()=>setState(()=>average=!average),child:const '
                         "Text('Toggle average')),\n"
                         '  NgButton(onPressed:()=>setState(()=>empty=!empty),child:const '
                         "Text('Toggle empty data')),\n"
                         '  NgButton(onPressed:()=>setState(()=>records=data(2)),child:const '
                         "Text('Update values')),\n"
                         ' ]),\n'
                         ' Text(\'Row totals ${rowTotals?"shown":"hidden"} · Column totals '
                         '${columnTotals?"shown":"hidden"} · Selection '
                         '${locked?"locked":"enabled"}\'),\n'
                         ' NgPivotGrid(items:empty?const '
                         '[]:records,aggregate:average?NgAggregate.average:NgAggregate.sum,showRowTotals:rowTotals,showColumnTotals:columnTotals,selectionReadOnly:locked,\n'
                         "  valueFormatter:(v)=>v==null?'No value':'${v.toStringAsFixed(1)} "
                         "credits',rowLabel:(v)=>v.isEmpty?'Unassigned':'Team "
                         "$v',columnLabel:(v)=>'Period $v',totalText:'All',emptyText:'No matching "
                         "deliveries',\n"
                         '  onCellSelected:(p)=>setState(()=>message=\'${p.row??"(total)"} / '
                         '${p.column??"(total)"} · ${p.records.length} records · IDs: '
                         '${p.records.map((r)=>r.id).join(",")}\')),\n'
                         " Text('Last drilldown: $message'),\n"
                         ']);',
                 'notes': 'NgPivotRecord contains a unique nonblank ID, string dimensions and one '
                          'nullable finite numeric value. RowField/ColumnField must be nonblank. '
                          'Raw dimension keys sort lexically; a missing key is the blank string. '
                          'Sum/Average/Min/Max use numeric values; Count includes records with '
                          'null values. Totals always aggregate original records, so an average is '
                          'not an average of averages.\n'
                          '\n'
                          'ShowRowTotals/showRowTotals controls the last column of per-row totals. '
                          'ShowColumnTotals/showColumnTotals controls the bottom row of per-column '
                          'totals. Both default true; the grand total is visible only when both '
                          'are true. Visibility changes presentation, not aggregation. '
                          'ValueFormatter/valueFormatter receives the nullable aggregate and '
                          'returns plain text for visible and accessible values; null means no '
                          'numeric result or overflow. RowLabel/rowLabel and '
                          'ColumnLabel/columnLabel format raw keys, including the blank string, '
                          'without changing sorting or callback keys. TotalText/totalText labels '
                          'totals independently of ordinary keys; EmptyText/emptyText replaces the '
                          'no-data message. These are plain-text formatters, not arbitrary '
                          'widget/HTML templates.\n'
                          '\n'
                          'SelectionReadOnly/selectionReadOnly blocks cell and total actions while '
                          'keeping values readable. Missing callbacks also disable these actions. '
                          'Input updates still work while locked. Stale callbacks after parent '
                          'updates or disposal cannot emit old data. Cell callbacks contain '
                          'original records in a read-only collection; null Row/Column denotes a '
                          'total, while an empty string denotes a blank dimension. Replace input '
                          'lists and dimension dictionaries instead of mutating them. This '
                          'component emits drilldown requests and does not own current selection; '
                          'the example retains Last drilldown as application history after data '
                          'changes. Filter Items/items before passing them in. Multiple grouping '
                          'levels, measures, OLAP, export, virtualization and a drag/drop '
                          'configurator remain unimplemented.'},
 'NgEditor': {'title': 'Structured document editor',
 'use': 'Edit a small document as typed blocks with a separate preview.',
 'blazor': '<div class="row">\n'
           '<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>\n'
           '<NgButton OnClick="()=>readOnly=!readOnly">Toggle read-only</NgButton>\n'
           '<NgButton OnClick="Reset">Replace document</NgButton>\n'
           '<NgButton OnClick="Save">Save JSON</NgButton>\n'
           '</div>\n'
           '<p>Acceptance: @(accept ? "enabled" : "rejected") · Accepted first block: '
           '@document.Blocks[0].Text</p>\n'
           '<NgEditor Label="Project description" Value="document" ValueChanged="Change" '
           'ReadOnly="readOnly"/>\n'
           '<pre>@saved</pre>\n'
           '@code {\n'
           '    private NgDocument document = Sample();\n'
           '    private bool accept = true, readOnly;\n'
           '    private string saved = "";\n'
           '    private static NgDocument Sample() => new([\n'
           '        new("Project plan", NgBlockKind.Heading1),\n'
           '        new("Agree on requirements", NgBlockKind.Bullet),\n'
           '        new("Review the result", NgBlockKind.Bullet, Bold: true)\n'
           '    ]);\n'
           '    private void Change(NgDocument next) { if(accept) document=next; }\n'
           '    private void Reset() => document=new([new("Imported brief"),new("Review imported '
           'content")]);\n'
           '    private void Save() => saved=document.ToJson();\n'
           '}',
 'dart': 'NgDocument document = NgDocument(blocks: const [\n'
         "  NgDocumentBlock(text: 'Project plan', kind: NgBlockKind.heading1),\n"
         "  NgDocumentBlock(text: 'Agree on requirements', kind: NgBlockKind.bullet),\n"
         "  NgDocumentBlock(text: 'Review the result', kind: NgBlockKind.bullet, bold: true),\n"
         ']);\n'
         'bool accept = true, readOnly = false;\n'
         "String saved = '';\n"
         'Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, '
         'children: [\n'
         '  Wrap(spacing: 8, runSpacing: 8, children: [\n'
         "    NgButton(onPressed: () => setState(() => accept = !accept), child: const Text('Toggle "
         "acceptance')),\n"
         "    NgButton(onPressed: () => setState(() => readOnly = !readOnly), child: const Text('Toggle "
         "read-only')),\n"
         '    NgButton(onPressed: () => setState(() => document = NgDocument(blocks: const '
         "[NgDocumentBlock(text: 'Imported brief'), NgDocumentBlock(text: 'Review imported "
         "content')])), child: const Text('Replace document')),\n"
         '    NgButton(onPressed: () => setState(() => saved = document.toJson()), child: const '
         "Text('Save JSON')),\n"
         '  ]),\n'
         '  Text(\'Acceptance: ${accept ? "enabled" : "rejected"} · Accepted first block: '
         "${document.blocks.first.text}'),\n"
         "  NgEditor(label: 'Project description', value: document, readOnly: readOnly,\n"
         '    onChanged: (v) => setState(() { if (accept) document = v; })),\n'
         '  Text(saved),\n'
         ']);',
 'notes': '### Editing\n'
          'Select a block, change Block text and press Apply text. Until applied, the local draft is '
          'not included in callbacks, preview or export. Block type supports paragraphs, level 1/2 '
          'headings, bullet/numbered items and quotes. Bold, Italic, Underline and Alignment apply to '
          'the entire block, not a selected text range.\n'
          '\n'
          'Changing selection/type/alignment/formatting, Add block and Move automatically applies the '
          'draft; one accepted action creates one history entry. Add inserts a paragraph after the '
          'current block. Move preserves selection. Delete discards the selected draft; deleting the '
          'final block leaves one empty paragraph. Undo/Redo stores the last 50 accepted operations and '
          'discards an unapplied draft only when the history proposal is accepted.\n'
          '\n'
          '### State and storage\n'
          'Value is an immutable NgDocument controlled by the parent. ValueChanged/onChanged proposes a '
          'new instance: return that exact instance to accept the operation. Until accepted, the '
          'preview, export, selection and history retain the accepted document. Keeping the old Value '
          'rejects the proposal and retains the draft. Flutter hosts must rebuild after acceptance or '
          'rejection (as in this example). A different returned instance is an independent replacement, '
          'even if its JSON is equivalent. Accept or reject within the event-driven update; late '
          'asynchronous responses are parent-owned replacements and must be guarded by the host against '
          'newer documents. An independent replacement (import or another file) resets history and '
          'draft; do not manufacture an equivalent new instance on every render. ReadOnly or an absent '
          'callback disables edits and history while preserving block inspection. Switching blocks in '
          'this mode discards the unsaved draft without a callback. Discard draft restores the selected '
          'accepted text without changing the document or history, and is also available while '
          'read-only. Flutter presents read-only text explicitly instead of a disabled editor input. '
          'Captured actions from an earlier parent update, selection or disposed editor are ignored. '
          'NgEditor is not an InputBase/FormField: the host validates document business rules.\n'
          '\n'
          'ToJson/toJson produces the shared version-1 format. Restore with '
          'NgDocument.FromJson/fromJson, catch ArgumentException/ArgumentError and preserve the current '
          'document on failure. ToHtml/toHtml exports applied blocks only, escapes text, groups '
          'adjacent list items and converts newlines to br. It returns a fragment without '
          'theme/container. Store JSON as the editable source; HTML import is not supported. The '
          'component does not upload or write files. The Editor gallery demonstrates Save/Restore.\n'
          '\n'
          '### Keyboard and limits\n'
          'Tab navigates controls; Enter/Space activates buttons. The textarea uses ordinary multiline '
          'input. Document Undo/Redo buttons are separate from operating-system text-input undo; there '
          'are no custom Ctrl+Z/Ctrl+Y shortcuts.\n'
          '\n'
          'Limits: 1–100 blocks, 10,000 UTF-16 units per block, 100,000 total, 1,000,000 units of input '
          'JSON. The model checks each operation. No nested lists, links, images, tables, font picker, '
          'selection formatting, HTML/Word import, PDF/print, collaboration, AI or virtualization. '
          'Native mobile and full screen-reader verification remain separate.'},
 'NgDiagram': {'title': 'Interactive diagram',
 'use': 'Display and edit a graph of nodes and directed or undirected connections.',
 'blazor': '<div class="row">\n'
           '<NgButton OnClick="()=>readOnly=!readOnly">Toggle move lock</NgButton>\n'
           '<NgButton OnClick="()=>selectionReadOnly=!selectionReadOnly">Toggle selection '
           'lock</NgButton>\n'
           '<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>\n'
           '<NgButton OnClick="()=>graph=Sample(120,140)">Replace graph</NgButton>\n'
           '<NgButton OnClick="()=>graph=graph.Nodes.Count==0?Sample():new()">Toggle empty '
           'graph</NgButton>\n'
           '</div>\n'
           '<p>Movement: @(readOnly?"locked":"enabled") · Selection: '
           '@(selectionReadOnly?"locked":"enabled") · Acceptance: @(accept?"enabled":"rejected")</p>\n'
           '<p>Start position: @(graph.Nodes.Count==0?"none":$"{graph.Nodes[0].X}, {graph.Nodes[0].Y}") '
           '· Move proposals: @moves</p>\n'
           '<NgDiagram Label="Process" Value="graph" ValueChanged="Change" ReadOnly="readOnly" '
           'SelectionReadOnly="selectionReadOnly"\n'
           '    NodeLabel="@(n=>$"Task {n.Text}")" EdgeLabel="@(e=>$"Flow {e.Text}")" '
           'EmptyText="Nothing to connect"\n'
           '    @bind-SelectedNodeId="selectedNode" @bind-SelectedEdgeId="selectedEdge"/>\n'
           '<p>Node: @(selectedNode??"none") · Connection: @(selectedEdge??"none")</p>\n'
           '@code {\n'
           '    private string? selectedNode, selectedEdge;\n'
           '    private bool readOnly,selectionReadOnly;\n'
           '    private bool accept=true;\n'
           '    private int moves;\n'
           '    private NgDiagramModel graph=Sample();\n'
           '    private static NgDiagramModel Sample(double x=40,double y=100)=>new([\n'
           '        new("start","Start",x,y,Shape:NgDiagramShape.Ellipse),\n'
           '        new("work","Processing",360,100)\n'
           '    ],[new("next","start","work","Continue")]);\n'
           '    private void Change(NgDiagramModel next){moves++;if(accept)graph=next;}\n'
           '}',
 'dart': 'NgDiagramModel sample([double x=40,double y=100]) => NgDiagramModel(nodes: [\n'
         "  NgDiagramNode('start', 'Start', x, y, shape: NgDiagramShape.ellipse),\n"
         "  const NgDiagramNode('work', 'Processing', 360, 100),\n"
         "], edges: const [NgDiagramEdge('next', 'start', 'work', text: 'Continue')]);\n"
         'late NgDiagramModel graph=sample();\n'
         'String? selectedNode, selectedEdge;\n'
         'bool readOnly=false, selectionReadOnly=false, accept=true;\n'
         'int moves=0;\n'
         'Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch, '
         'children:[\n'
         '  Wrap(spacing:8,runSpacing:8,children:[\n'
         "    NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Toggle move "
         "lock')),\n"
         '    NgButton(onPressed:()=>setState(()=>selectionReadOnly=!selectionReadOnly),child:const '
         "Text('Toggle selection lock')),\n"
         "    NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle "
         "acceptance')),\n"
         "    NgButton(onPressed:()=>setState(()=>graph=sample(120,140)),child:const Text('Replace "
         "graph')),\n"
         '    '
         'NgButton(onPressed:()=>setState(()=>graph=graph.nodes.isEmpty?sample():NgDiagramModel()),child:const '
         "Text('Toggle empty graph')),\n"
         '  ]),\n'
         '  Text(\'Movement: ${readOnly?"locked":"enabled"} · Selection: '
         '${selectionReadOnly?"locked":"enabled"} · Acceptance: ${accept?"enabled":"rejected"}\'),\n'
         '  Text(\'Start position: ${graph.nodes.isEmpty?"none":"${graph.nodes.first.x.round()}, '
         '${graph.nodes.first.y.round()}"} · Move proposals: $moves\'),\n'
         "  NgDiagram(label: 'Process', value: graph, readOnly:readOnly, "
         'selectionReadOnly:selectionReadOnly,\n'
         "    nodeLabel:(n)=>'Task ${n.text}',edgeLabel:(e)=>'Flow ${e.text}',emptyText:'Nothing to "
         "connect',\n"
         '    onChanged: (v) => setState(() {moves++;if(accept)graph=v;}),\n'
         '    selectedNodeId: selectedNode, selectedEdgeId: selectedEdge,\n'
         '    onSelectedNodeIdChanged: (v) => setState(() => selectedNode = v),\n'
         '    onSelectedEdgeIdChanged: (v) => setState(() => selectedEdge = v)),\n'
         '  Text(\'Node: ${selectedNode??"none"} · Connection: ${selectedEdge??"none"}\'),\n'
         ']);',
 'notes': '### Selection and movement\n'
          'Click a node or connection to select it. The other selection type is first cleared through '
          'its callback with null. Store both selected IDs. Unknown IDs are not highlighted; remove '
          'stale selection when deleting data. Dragging previews a new position, and only pointer '
          'release proposes coordinates through ValueChanged/onChanged. Accept by returning the '
          'proposed graph; rejection retains the original coordinates and removes the drag preview. '
          'Selection is a separate proposal and may still change when movement is rejected. Escape '
          'cancels drag. Tab focuses nodes; Enter/Space selects; arrows move 10 units, Shift+arrow '
          'moves 1. Movement stays inside the canvas. Flutter exposes keyboard-selectable Connections; '
          'Blazor SVG connections are focusable.\n'
          '\n'
          '### Labels and empty state\n'
          '\n'
          'NodeLabel/nodeLabel and EdgeLabel/edgeLabel format plain-text display and accessible names '
          'without changing raw IDs, coordinates or JSON. Full labels are used in accessible names and '
          'tooltips/list entries; canvas labels may be shortened to fit. EmptyText/emptyText replaces '
          'the empty-graph message. The default values retain existing labels. These are not arbitrary '
          'templates.\n'
          '\n'
          '### Zoom and viewport\n'
          'Zoom changes by 25 percentage points, within 25–200%. Fit width fits the entire canvas '
          'width; 100% resets zoom. The viewport is 420 logical/CSS pixels tall, with internal '
          'scrolling. Zoom does not alter model coordinates or JSON. Fit diagram fits node bounds in '
          'both axes with 24 px padding and centers by scrolling; it preserves selection and works in '
          'ReadOnly. Empty graphs disable it. Minimum zoom can still require scrolling for large '
          'graphs; canvas boundaries constrain centering and long connection labels may extend beyond '
          'bounds. Fitting is explicit, not automatic layout.\n'
          '\n'
          'NgDiagramModel.FitView/fitView(viewportWidth,viewportHeight) returns NgDiagramView '
          '(Zoom/ScrollX/ScrollY or lowerCamelCase). Sizes must be finite and positive. An empty graph '
          'returns 100% and zero scroll.\n'
          '\n'
          '### Model and persistence\n'
          'Value is immutable. Store the new graph from callbacks; an independent replacement cancels '
          'active drag. ReadOnly or a missing ValueChanged/onChanged disables movement but retains '
          'selection, zoom and scrolling. SelectionReadOnly/selectionReadOnly independently disables '
          'node and edge selection; movement can remain enabled. Missing selection callbacks disable '
          'their respective selection action without clearing the other selection. A successful '
          'selection first requests clearing the opposite ID; both IDs remain parent-owned. Any parent '
          'update cancels active drag and invalidates captured actions, including replacement graphs '
          'reusing node IDs. Zoom also cancels drag. Blazor rechecks graph identity and permissions '
          'after awaiting selection callbacks, before proposing a move. Host-side asynchronous '
          'responses still need ordering against newer data. The application owns create/edit/delete '
          'actions and their permissions. The gallery shows a properties panel, connections, 20-change '
          'history and import; NgDiagram itself has no undo history.\n'
          '\n'
          'UpsertNode/UpsertEdge add or replace by ID. RemoveNode also removes incident edges; '
          'RemoveEdge keeps nodes. Move(id,x,y) clamps coordinates to the canvas and returns a new '
          'model. For example: graph = graph.Move("start",80,120), or graph = '
          "graph.move('start',80,120). ToJson/toJson and FromJson/fromJson use the shared version-1 "
          'Nextgen schema, not Telerik JSON. Catch invalid imports and retain the previous graph. No '
          'automatic file storage or upload.\n'
          '\n'
          '### Geometry and limits\n'
          'Shapes: rectangle, ellipse, diamond (PascalCase enum names in C#). Nodes store ID, text, '
          'top-left X/Y and width/height (default 160×80). Labels are visually shortened but available '
          'in tooltips/accessibility/properties. Connections run straight between shape boundaries '
          'along the centers; directed connections have an end arrow. On-canvas connection labels '
          'shorten to 24 characters.\n'
          '\n'
          'Canvas dimensions: 200–5000 (default 1000×600); up to 100 nodes and 200 edges. Nodes: 60–400 '
          '× 40–240, fully inside the canvas. IDs: 1–64 ASCII letters/digits/_/-, unique separately for '
          'nodes and edges. Node text is nonempty and at most 100 UTF-16 units; edge text 0–100. '
          'Coordinates are finite. Edges require two different existing nodes. Cycles and parallel '
          'edges are allowed; workflow rules belong to the application. Overlaps are not resolved '
          'automatically; coincident centers yield a zero-length line.\n'
          '\n'
          'No automatic layout, obstacle routing, connector drawing, pointer resizing, groups, multiple '
          'selection, image/templates, export, minimap, pinch zoom or collaboration. Blazor loads '
          'diagram.js automatically from static web assets and requires interactive rendering; if drag '
          'fails, check the module and ValueChanged handling. Native/mobile and screen-reader audits '
          'remain separate.'},
 'NgPdfViewer': {'title': 'PDF viewer',
                 'use': 'Browse page thumbnails, navigate, search and copy text from PDF documents.',
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
                          'Thumbnails opens a collapsible page rail. Buttons show page numbers and mark the current '
                          'page with aria-current. Click or use Tab then Enter/Space to navigate. Previous/Next, '
                          'direct page entry and search results keep the rail selection synchronized. Only visible '
                          'previews render, sequentially; each raster is at most 224 by 288 pixels. Scrolling '
                          'away, hiding the rail or replacing the document releases preview canvases. A failed '
                          'preview retains its page button. The rail starts closed for each document and narrows '
                          'on small screens.\n\n'
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
                          'rendered at a time in the main viewport; raster output is capped at 16 million pixels and an '
                          '8192-pixel side, reducing quality at extreme zoom if necessary. Corrupt files, '
                          'CORS/access errors and password-protected documents show an error and allow '
                          'another file. No passwords, forms, annotations, signatures, PDF links, print, '
                          'OCR or built-in localization. PDF JavaScript/actions are not '
                          'executed.\n'
                          '\n'
                          'Flutter currently supports this component on Web only; native displays an '
                          'explicit unsupported message. Native support and full screen-reader certification '
                          'are not part of this release.'},
 'NgMap': {'title': 'Interactive map',
 'use': 'Display geographic markers, paths and polygons over an optional raster basemap.',
 'blazor': '<div class="row">\n'
           '<NgButton OnClick="()=>navigationLocked=!navigationLocked">Toggle navigation '
           'lock</NgButton>\n'
           '<NgButton OnClick="()=>selectionLocked=!selectionLocked">Toggle selection lock</NgButton>\n'
           '<NgButton OnClick="()=>clickLocked=!clickLocked">Toggle click lock</NgButton>\n'
           '<NgButton OnClick="()=>accept=!accept">Toggle acceptance</NgButton>\n'
           '<NgButton OnClick="()=>map=Sample(true)">Replace objects</NgButton>\n'
           '<NgButton OnClick="()=>map=map.Markers.Count==0?Sample():new()">Toggle empty '
           'map</NgButton>\n'
           '<NgButton OnClick="()=>view=new(50.4501,30.5234,10)">Reset view</NgButton>\n'
           '</div>\n'
           '<p>Selected: @(selected??"none") · View zoom: @view.Zoom · Selection requests: @selections '
           '· View requests: @views · Map clicks: @clicks</p>\n'
           '<p>Acceptance: @(accept?"enabled":"rejected")</p>\n'
           '<NgMap Label="Delivery map" Value="map" View="view" ViewChanged="ViewChanged" '
           'SelectedId="@selected" SelectedIdChanged="Select"\n'
           '    OnMapClick="Clicked" ClusterMarkers="true" NavigationReadOnly="navigationLocked" '
           'SelectionReadOnly="selectionLocked"\n'
           '    MapClickReadOnly="clickLocked" EmptyText="No delivery points"/>\n'
           '@code {\n'
           ' private string? selected;\n'
           ' private bool navigationLocked,selectionLocked,clickLocked;\n'
           ' private bool accept=true;\n'
           ' private int selections,views,clicks;\n'
           ' private NgMapView view=new(50.4501,30.5234,13);\n'
           ' private NgMapModel map=Sample();\n'
           ' private static NgMapModel Sample(bool updated=false)=>new([\n'
           '   new("office",updated?"Office updated":"Office",new(50.4501,30.5234)),\n'
           '   new("depot","Depot",new(50.4501,30.5234)),new("park","Park",new(50.4466,30.5410))\n'
           ' ],[new("line","Delivery line",[new(50.4501,30.5234),new(50.4466,30.5410)])]);\n'
           ' private void Select(string? id){selections++;if(accept)selected=id;}\n'
           ' private void ViewChanged(NgMapView next){views++;if(accept)view=next;}\n'
           ' private void Clicked(NgMapPoint point){clicks++;}\n'
           '}',
 'dart': 'NgMapModel sample([bool updated=false]) => NgMapModel(markers:[\n'
         "  NgMapMarker('office',updated?'Office updated':'Office',NgMapPoint(50.4501,30.5234)),\n"
         "  NgMapMarker('depot','Depot',NgMapPoint(50.4501,30.5234)),\n"
         "  NgMapMarker('park','Park',NgMapPoint(50.4466,30.5410)),\n"
         "],paths:[NgMapPath('line','Delivery "
         "line',[NgMapPoint(50.4501,30.5234),NgMapPoint(50.4466,30.5410)])]);\n"
         'late NgMapModel map=sample();\n'
         'NgMapView view=NgMapView(latitude:50.4501,longitude:30.5234,zoom:13);\n'
         'String? selected;\n'
         'bool navigationLocked=false,selectionLocked=false,clickLocked=false,accept=true;\n'
         'int selections=0,views=0,clicks=0;\n'
         'Widget build(BuildContext '
         'context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\n'
         '  Wrap(spacing:8,runSpacing:8,children:[\n'
         '    NgButton(onPressed:()=>setState(()=>navigationLocked=!navigationLocked),child:const '
         "Text('Toggle navigation lock')),\n"
         '    NgButton(onPressed:()=>setState(()=>selectionLocked=!selectionLocked),child:const '
         "Text('Toggle selection lock')),\n"
         "    NgButton(onPressed:()=>setState(()=>clickLocked=!clickLocked),child:const Text('Toggle "
         "click lock')),\n"
         "    NgButton(onPressed:()=>setState(()=>accept=!accept),child:const Text('Toggle "
         "acceptance')),\n"
         "    NgButton(onPressed:()=>setState(()=>map=sample(true)),child:const Text('Replace "
         "objects')),\n"
         '    '
         'NgButton(onPressed:()=>setState(()=>map=map.markers.isEmpty?sample():NgMapModel()),child:const '
         "Text('Toggle empty map')),\n"
         '    '
         'NgButton(onPressed:()=>setState(()=>view=NgMapView(latitude:50.4501,longitude:30.5234,zoom:10)),child:const '
         "Text('Reset view')),\n"
         '  ]),\n'
         '  Text(\'Selected: ${selected??"none"} · View zoom: ${view.zoom} · Selection requests: '
         "$selections · View requests: $views · Map clicks: $clicks'),\n"
         '  Text(\'Acceptance: ${accept?"enabled":"rejected"}\'),\n'
         "  NgMap(label:'Delivery map',value:map,view:view,selectedId:selected,clusterMarkers:true,\n"
         '    '
         "navigationReadOnly:navigationLocked,selectionReadOnly:selectionLocked,mapClickReadOnly:clickLocked,emptyText:'No "
         "delivery points',\n"
         '    onSelectedIdChanged:(id)=>setState((){selections++;if(accept)selected=id;}),\n'
         '    onViewChanged:(next)=>setState((){views++;if(accept)view=next;}),\n'
         '    onMapClick:(point)=>setState(()=>clicks++)),\n'
         ']);',
 'notes': '### Hosting and tiles\n'
          'Blazor requires interactive rendering and static assets. With UseStaticFiles map .mjs to '
          'text/javascript for the clustering module (gallery Program.cs). Leaflet 1.9.4 is packaged in '
          'map-viewer and Flutter assets; no CDN/script tags are needed. Flutter implements Web; native '
          'shows an unsupported-platform message.\n'
          '\n'
          'TileUrlTemplate must contain {z}, {x}, {y}; relative and HTTP(S) URLs are supported. Empty '
          'source shows a grid and your objects without a basemap. Attribution is required for a '
          'configured provider; AttributionUrl adds a link. Attribution/object labels are plain text. '
          'Choose a provider supporting zoom 0–19 and your usage terms. Custom headers, bearer tokens, '
          'TMS and vector tiles are not supported.\n'
          '\n'
          'For OpenStreetMap keep attribution, normal Referrer and browser cache; do not bulk-prefetch '
          'or download offline. The public service has no SLA; review the provider terms and [tile '
          'policy](https://operations.osmfoundation.org/policies/tiles/). Object labels are not sent to '
          'the provider, but IP, Referrer and tile coordinates are. Host CSP must permit local '
          'frames/scripts/styles, Leaflet inline styles and provider images.\n'
          '\n'
          '### Data model\n'
          'NgMapPoint accepts latitude first, longitude second: finite latitude ±85.05112878, longitude '
          '±180. NgMapMarker has ID, label and position. NgMapPath is a straight polyline with at least '
          '2 points, or a closed polygon with at least 3; closing is automatic. These are geographic '
          'lines, not road routing. No date-line crossing, holes or multipolygons.\n'
          '\n'
          'NgMapModel copies collections and exposes read-only data. IDs are unique across markers and '
          'paths: 1–64 ASCII letters/digits/_/-. Labels: 1–200 characters, not only whitespace. Limits: '
          '500 markers, 100 paths/polygons, 5,000 total path points. Invalid input raises '
          'ArgumentException/ArgumentError. Replace the model to update; there is no automatic '
          'persistence/loading.\n'
          '\n'
          '### View and events\n'
          'View defines center and integer zoom 0–19 (initial 0,0,2). Drag pans; wheel/double-click/+/- '
          'zoom. Focused maps accept arrows and +/-. Fit data fits all objects with padding and zoom at '
          'most 14; empty models disable it. Data changes do not auto-fit. The center is limited to '
          'world bounds.\n'
          '\n'
          'When ViewChanged/onViewChanged is supplied, View is controlled: return the proposed view to '
          'accept navigation, or rebuild with the previous View to reject it. A rejected view is '
          'restored without a feedback callback. With no view callback, navigation is local; changing '
          'the supplied View still resets it. Parent-driven view updates do not emit view events. '
          'Flutter hosts must rebuild after acceptance or rejection. Async host responses need ordering '
          'against newer state. SelectedId is one object ID or null; selection callbacks report '
          'marker/path IDs or null after Clear selection. Unknown IDs appear unselected without '
          'correcting parent state. Selection requires SelectedIdChanged/onSelectedIdChanged and is '
          'parent-controlled: a rejected proposal leaves highlighting and popup unchanged. Objects '
          'buttons are keyboard accessible and open accepted object popups without automatic panning; '
          'use Fit data to bring distant objects into view; objects are also clickable directly. '
          'OnMapClick reports a coordinate only for free background, not object clicks. To add a '
          'marker, build a new NgMapModel with the old items and a uniquely identified marker. No '
          'address/geocoding is returned.\n'
          '\n'
          'Height: 400–1200, default 520. Below 540 px the Objects list moves under the map and scrolls '
          'horizontally. Label also names the iframe. Blazor Dark is explicit; Flutter reads Theme. '
          'Theme/model updates preserve the iframe; controlled views reconcile to the supplied View on '
          'each update, while local navigation keeps its view when the supplied View is unchanged; '
          'provider imagery is not inverted.\n'
          '\n'
          '### Independent interaction locks\n'
          '\n'
          'NavigationReadOnly/navigationReadOnly disables user pan, wheel/touch/double-click/keyboard '
          'zoom, zoom controls and Fit data. Parent view updates still apply. '
          'SelectionReadOnly/selectionReadOnly disables object selection, cluster member selection and '
          'Clear selection; missing selection callbacks have the same effect. '
          'MapClickReadOnly/mapClickReadOnly independently suppresses background-click callbacks; '
          'missing click callbacks also suppress events. All locks default to false.\n'
          '\n'
          'An updated configuration cancels active navigation. Events carry a configuration revision: '
          'old iframe messages cannot select reused IDs or change a replacement view. Invalid message '
          'shapes, out-of-range coordinates and messages after disposal are ignored. '
          'EmptyText/emptyText customizes the object-list empty message. Cluster zoom respects '
          'navigation locks; coincident points or locked navigation can still show the chooser when '
          'selection is enabled. The example uses no basemap and makes no tile requests.\n'
          '\n'
          '### Clustering\n'
          'ClusterMarkers defaults to false. ClusterRadius is an integer 20–120 CSS px, default 60, '
          'validated even when clustering is off. Distance is screen distance at the current zoom, not '
          'meters. Markers sort by ID and group around the first point; neighbor chains do not merge '
          'indefinitely. Input ordering and panning do not change membership; zoom recalculates groups. '
          'Date-line points are not clustered together.\n'
          '\n'
          'Activating a cluster zooms at least one level, up to 19. Coincident points or maximum zoom '
          'open a scrollable member chooser. Choosing a member triggers normal selection and displays '
          'its individual marker/popup. Clusters have no public object ID and do not trigger background '
          'clicks. A selected marker stays outside clusters; Clear selection rejoins it, so a cluster '
          'count excludes the selected marker while the total includes every marker. Objects selection '
          'behaves the same way.\n'
          '\n'
          'Clusters support Tab/Enter and popup buttons. Data/clustering updates preserve the view but '
          'may close a regrouped popup; theme changes retain groups. Paths are not clustered. The '
          '500-marker model limit still applies: this is not server aggregation. Dense markers and Same '
          'location gallery scenarios demonstrate it without external tiles.\n'
          '\n'
          '### Status and omissions\n'
          'No objects, No basemap configured, Loading tiles, Tiles loaded and Some map tiles '
          'unavailable distinguish data and provider states. Objects/selection still work when tiles '
          'fail. Navigation/source changes request new tiles. One raster basemap only; no geocoding, '
          'routing, GeoJSON import, bubble layers, geometry editing, export or offline mode. Filter '
          'large datasets in the application before supplying them.'},
 'NgPromptBox': {'title': 'Prompt input',
 'use': 'Compose a multiline request with explicit submission and cancellation.',
 'blazor': '<NgButton OnClick="()=>limit=limit==80?8:80">Toggle length limit</NgButton>\n'
           '<NgPromptBox Label="Prompt" @bind-Value="prompt" MaxLength="limit" Busy="busy" '
           'OnSubmit="Submit" OnCancel="Cancel"/>\n'
           '<p>@result</p>\n'
           '@code {\n'
           ' private string prompt="",result=""; private bool busy; private int revision; private int '
           'limit=80;\n'
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
         'int revision = 0, limit = 80;\n'
         'Future<void> submit(String text) async {\n'
         '  final request = ++revision;\n'
         '  setState(() => busy = true);\n'
         '  await Future<void>.delayed(const Duration(milliseconds: 700));\n'
         '  if (!mounted || request != revision) return;\n'
         "  setState(() { result = 'Received prompt: $text'; busy = false; });\n"
         '}\n'
         'Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, '
         'children: [\n'
         ' NgButton(onPressed: () => setState(() => limit = limit == 80 ? 8 : 80), child: const '
         "Text('Toggle length limit')),\n"
         " NgPromptBox(label: 'Prompt', value: prompt, maxLength: limit,\n"
         '  onChanged: (v) => setState(() => prompt = v), busy: busy,\n'
         '  onSubmit: submit,\n'
         "  onCancel: () => setState(() { revision++; busy = false; result = 'Cancelled'; })), Text(result)]);",
 'notes': 'Value/value supplies the draft. Store ValueChanged/onChanged and pass the value back; '
          'unchanged parent values preserve local edits. External value replacement updates the field. '
          'MaxLength is 1–8000 UTF-16 code units, default 8000; emoji may occupy two units. External '
          'values may contain up to 8000 units. A value or retained draft above MaxLength stays visible '
          'with an error and Send disabled, so reducing the limit never silently truncates text. Input '
          'beyond the limit is rejected unless it shortens an already oversized draft; further deletion '
          'remains possible. Values over the absolute 8000-unit cap are rejected. Blank input cannot be '
          'submitted. Send trims outer whitespace; Enter inserts a newline. Tab followed by Enter/Space '
          'activates buttons; no special submit shortcut is installed.\n'
          '\n'
          'Busy makes the input read-only and replaces Send with Cancel. The parent owns the '
          'asynchronous request, busy state, result/error display and cancellation. OnCancel only '
          'signals the parent: it does not stop a network request by itself. Use a cancellation '
          'token/transport adapter and invalidate late responses. The example demonstrates this '
          'ownership. ReadOnly prevents submission and editing; a busy Cancel remains available when '
          'its callback exists. A missing submit/cancel callback disables the corresponding action.\n'
          '\n'
          'This is an input control, not an AI client or form-validation engine. Use NgAIPrompt for '
          'history and response actions. Attachments, speech input, model selection, streaming and '
          'provider integration are not included. Do not put provider secrets in browser code.\n'
          '\n'
          'Actions recheck the current busy/read-only state and current callbacks, including retained '
          'actions after a rebuild or disposal. Cancel requires Busy; ReadOnly alone does not disable '
          'cancellation.\n'},
 'NgAIPrompt': {'title': 'AI prompt interface',
 'use': 'Compose requests, inspect responses and manage retries, history and feedback.',
 'blazor': '<div class="ng-prompt-actions">\n'
           ' <NgButton OnClick="()=>generationLocked=!generationLocked">Toggle generation '
           'lock</NgButton>\n'
           ' <NgButton OnClick="()=>historyLocked=!historyLocked">Toggle history lock</NgButton>\n'
           ' <NgButton OnClick="()=>feedbackLocked=!feedbackLocked">Toggle feedback lock</NgButton>\n'
           '</div>\n'
           '<NgAIPrompt Label="Assistant" @bind-Value="prompt" Generate="Generate"\n'
           ' GenerationReadOnly="generationLocked" HistoryReadOnly="historyLocked" '
           'FeedbackReadOnly="feedbackLocked"\n'
           ' Suggestions="suggestions" OnCompleted="Completed" OnFeedback="Feedback"/>\n'
           '<p>Completed: @completed · Feedback events: @feedbackCount</p>\n'
           '@code {\n'
           ' private string prompt="Draft a meeting agenda";\n'
           ' private bool generationLocked,historyLocked,feedbackLocked;\n'
           ' private int completed,feedbackCount;\n'
           ' private string[] suggestions=["Draft a meeting agenda","Suggest next steps"];\n'
           ' private async Task<string> Generate(string text,CancellationToken cancellation) {\n'
           '  await Task.Delay(1200,cancellation);\n'
           '  return $"Local example response to: {text}"; // Connect your application service here.\n'
           ' }\n'
           ' private void Completed(NgPromptResponse response){completed++;}\n'
           ' private void Feedback(NgPromptFeedback feedback){feedbackCount++;}\n'
           '}',
 'dart': "String prompt = 'Draft a meeting agenda';\n"
         'bool generationLocked = false, historyLocked = false, feedbackLocked = false;\n'
         'int completed = 0, feedbackCount = 0;\n'
         'Future<String> generate(String text, NgPromptCancellation cancellation) async {\n'
         '  await Future<void>.delayed(const Duration(milliseconds: 1200));\n'
         '  cancellation.throwIfCancelled();\n'
         "  return 'Local example response to: $text'; // Connect your application service here.\n"
         '}\n'
         'Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, '
         'children: [\n'
         ' Wrap(spacing: 8, runSpacing: 8, children: [\n'
         '  NgButton(onPressed: () => setState(() => generationLocked = !generationLocked), child: '
         "const Text('Toggle generation lock')),\n"
         '  NgButton(onPressed: () => setState(() => historyLocked = !historyLocked), child: const '
         "Text('Toggle history lock')),\n"
         '  NgButton(onPressed: () => setState(() => feedbackLocked = !feedbackLocked), child: const '
         "Text('Toggle feedback lock')),\n"
         ' ]),\n'
         " NgAIPrompt(label: 'Assistant', value: prompt, onChanged: (v) => setState(() => prompt = v),\n"
         '  generate: generate, generationReadOnly: generationLocked, historyReadOnly: historyLocked,\n'
         '  feedbackReadOnly: feedbackLocked,\n'
         "  suggestions: const ['Draft a meeting agenda', 'Suggest next steps'],\n"
         '  onCompleted: (_) => setState(() => completed++), onFeedback: (_) => setState(() => '
         'feedbackCount++)),\n'
         " Text('Completed: $completed · Feedback events: $feedbackCount'),\n"
         ']);',
 'notes': '### Provider contract\n'
          'Blazor Generate is Func<string,CancellationToken,Task<string>>; Flutter generate is '
          'NgPromptGenerator: Future<String> Function(String,NgPromptCancellation). The handler '
          'receives a captured, trimmed prompt and returns complete response text. Without it the input '
          'is disabled. The example/gallery uses a deterministic delayed local handler, not an AI '
          'model.\n'
          '\n'
          'The application owns authentication, model choice, rate limits, timeouts and provider calls. '
          'Keep provider credentials on your backend. In Blazor pass CancellationToken into the HTTP/AI '
          'client. In Flutter connect cancellation.whenCancelled to transport cancellation; isCancelled '
          'and throwIfCancelled detect cancellation. Checking after await stops result processing, not '
          'the remote request or billing. The component itself makes no network requests.\n'
          '\n'
          '### Draft and request lifecycle\n'
          'Value/value and change callbacks control the draft. Maximum prompt: 8000 UTF-16 units. Up to '
          '8 nonempty suggestions, each at most 200 units. Suggestions fill the draft without sending. '
          'Enter inserts a newline; Send submits. Duplicate submission is blocked while busy. The user '
          'cannot edit during a request, but an external Value replacement changes the next draft, not '
          'the captured request.\n'
          '\n'
          'Cancel immediately releases the UI and signals cancellation. A new request may start '
          'immediately. Even if an older handler ignores cancellation, its late result/error cannot '
          'enter history or replace newer state. Disposal, ReadOnly, GenerationReadOnly or removing the '
          'handler also cancels pending work. ReadOnly keeps history browsing/copying available. '
          "Transport cancellation is the application's responsibility.\n"
          '\n'
          'Provider exceptions show a generic Generation failed. Try again. message; log details in '
          'your handler. Retry request uses the last failed prompt even if the draft changed. '
          'Empty/whitespace responses and responses over 32000 UTF-16 units are errors. Previous '
          'successful history survives failures. Timeouts belong to the application.\n'
          '\n'
          '### Responses and events\n'
          'The last 20 successful responses are kept in memory; oldest entries are evicted. IDs '
          'increase throughout the component session, including after Clear history. Selecting history '
          "changes the displayed response. Regenerate runs that response's original prompt. Clear "
          'removes history/selection/votes and cancels work in the public session API; the UI button is '
          'disabled while busy. History is not durable and is lost on component disposal.\n'
          '\n'
          'NgPromptResponse contains Id/id, Prompt/prompt and Text/text. OnCompleted fires once for '
          'each accepted successful response, never for cancellation/failure. NgPromptFeedback contains '
          'the response and Helpful/helpful: true, false or null for a cleared vote. Clicking the same '
          'vote toggles it off; votes do not call the provider. Callback exceptions belong to the host '
          'application.\n'
          '\n'
          'Responses render as plain text, with no HTML/Markdown execution. Copy response uses the '
          'browser/platform clipboard; when unavailable, select the text manually. Clipboard '
          'permissions and secure-context rules depend on the host. There are no attachments, speech, '
          'command templates, streaming, provider SDKs, model picker, durable conversations or '
          'automatic moderation.\n'
          '\n'
          '### Session API and integration\n'
          'NgPromptSession exposes read-only Responses/responses, Selected/selected, IsBusy/isBusy, '
          'Error/error and Status/status. RunAsync/run invokes a handler; Cancel/cancel invalidates '
          'pending work; Select/select changes selection; Clear/clear resets history; Dispose/dispose '
          'ends the session. Blazor Changed and Flutter ChangeNotifier report state changes. Use it on '
          'the UI thread, dispose it in its owner, and do not mutate response collections. The '
          'component owns its own session; use the public session only when building a separate custom '
          'interface. Native mobile and full accessibility certification remain separate.\n'
          '\n'
          '### Independent permissions (0.45)\n'
          'GenerationReadOnly/generationReadOnly disables composition, suggestions, Send, Retry and '
          'Regenerate and cancels pending work. HistoryReadOnly/historyReadOnly prevents Clear history; '
          'reading, selecting and copying responses remain available. FeedbackReadOnly/feedbackReadOnly '
          'prevents voting. All default to false. ReadOnly applies all three restrictions. Missing '
          'generation handlers disable suggestions as well as composition; missing feedback handlers '
          'disable voting, with no local-only votes.\n'
          '\n'
          'Action handlers recheck current permissions and disposal, not just button appearance. '
          'Regenerate and feedback require the captured response still to be selected; removed '
          'suggestions and evicted/cleared history actions are ignored. Feedback remains available '
          'during generation for the selected previous response when permitted. History selection and '
          'copy remain available under every lock. The locks control UI behavior; application services '
          'must enforce their own authorization.\n'},
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

# 0.26: complete selection-button workbench, grouped as one delivery.
D['NgToggleButton']['notes'] = """
### Controlled selection and click events

Value/value is application-owned. Store ValueChanged/onChanged and pass the new value back. OnClick/onClick is an independent activation notification: selection is requested first, then click runs. Blazor awaits the selection callback; Flutter callbacks are synchronous. If selection handling throws, the click callback is not reached. A click-only toggle stays interactive but never changes its own value. With neither callback, or Disabled/disabled=true, it is disabled. Disable the control while an application request is pending; automatic async-operation locking is not supplied.

### Content and accessible names

Label/label remains required, nonblank and limited to 120 UTF-16 code units. ChildContent/child replaces visible content; Leading/leading supplies a decorative icon, image or avatar. These slots must contain display content, not nested buttons, links or inputs. AriaLabel/semanticLabel optionally overrides the main accessible name. Keep visible wording in the name. Blazor AriaLabelledBy overrides the label when its IDs resolve; AriaDescribedBy supplies help. Flutter uses semanticIdentifier/semanticHint. Names and hints must be nonblank when supplied. Templates do not replace the explicit name.

Id/Class/Title are Blazor DOM hooks. Flutter has no equivalent CSS-class contract; use its widget layout and semantics APIs. Blazor exports button/aria-pressed, Flutter retains Material's native checked semantics. These are platform-specific contracts, not a screen-reader certification.

### Focus and visibility

TabIndex/tabIndex accepts 0 (default) or -1 only. -1 skips Tab traversal without disabling pointer activation or explicit focus. Blazor FocusAsync() is available through @ref after interactive rendering; hidden or disabled controls do not receive focus. Flutter accepts an application-owned FocusNode; create it once, requestFocus(), and dispose it after removing its widget. Each enabled group item remains a separate Tab stop; Enter/Space activates it. There is no arrow-key radiogroup contract.

Visible/visible=false removes the action from layout, keyboard traversal and semantics. It does not reset the parent's selected state. If the application hides the focused action, it must choose the next focus target. Re-showing a button restores its controlled state, not its old focus.
"""
D['NgButtonGroup']['notes'] = """
### Mix choices with commands

Items/items contains NgOption records with stable IDs. IsCommand/isCommand is an optional predicate: false means toggle (the default), true means ordinary command. Commands invoke OnClick/onClick with their ID and never enter Value/value. Passing a command ID as selected throws, including when the command is hidden. If an item changes type at runtime, normalize selected IDs in the same parent update. Predicates and builders should be pure.

OnClick/onClick receives activations of both kinds. A toggle first requests a changed selection, then invokes click; a command invokes only click. A no-op selection, such as rejecting the last deselection with AllowEmpty=false, still produces click. Blazor awaits ValueChanged before OnClick; Flutter callbacks run synchronously. The group never performs command side effects. In the example, the parent handles Clear formatting by clearing its own value.

Toggles need either ValueChanged/onChanged or OnClick/onClick to be interactive. Click-only toggles retain controlled state. Commands need OnClick/onClick. Disabled/disabled and NgOption.disabled suppress both actions. Async work, busy-state locking and error reporting belong to the application.

### Selection, validation and visibility

Value/value is a list of selected toggle IDs even in single mode. Multiple/multiple=false accepts at most one selected ID; true toggles independently. AllowEmpty/allowEmpty=true permits removing the last selection; false prevents that user action but does not invent an initial value or reject an application-supplied empty list. Selection callbacks return new lists in item order; the input is not mutated.

Use at most 50 records, unique IDs of 1–64 ASCII letters/digits/underscores/hyphens and nonblank labels up to 120 UTF-16 code units. Selected IDs must be unique and present in Items/items. Removing records or switching to single mode requires normalizing the value in the same update. Disabled selected items remain valid.

IsVisible/isVisible=false hides a record from rendering, focus and accessibility without removing it from Items or Value. Hidden selections still participate in selection rules; selecting another toggle in single mode replaces a hidden selection. When all items are hidden, the empty message is No options even if the parent retains hidden selection. Restore visibility to show the selected state again. The application owns focus recovery when hiding the focused button.

### Content, naming and layout

ItemTemplate/itemBuilder replaces visible item content; LeadingTemplate/leadingBuilder supplies a decorative icon/avatar. Both use NgOption and must remain display-only. The accessible item name remains its label, even if the template uses abbreviated text. Command buttons have no pressed/checked state. Toggle buttons keep the existing selected semantics on each platform.

Label/label names the group. Blazor offers Id/Class, AriaLabelledBy and AriaDescribedBy; Flutter offers semanticIdentifier/semanticHint. Horizontal groups wrap; Vertical/vertical stacks. Control width through the containing CSS/widget layout. Tab/Shift+Tab visit enabled visible actions and Enter/Space activates them; arrows are not managed as a composite widget. The data-driven NgOption model differs from Telerik's declarative child-button API. Routes, native form submission/reset button types and content panels are not implemented by this group.
"""
appearance_notes = """

### Shared appearance and per-item overrides

Size/size accepts sm, md, lg. Rounded/rounded accepts sm, md, lg, full. FillMode/fillMode accepts solid, outline, flat, link, clear. ThemeColor/themeColor accepts base, primary, secondary, tertiary, info, success, warning, error, dark, light, inverse. Invalid tokens throw. Defaults are md/md/outline/primary, preserving Nextgen's selection emphasis rather than copying Telerik defaults. Colors adapt to the active theme; dark/light are readable theme tokens, not fixed black/white swatches. Exact theme pixels and ThemeBuilder compatibility are not claimed.

Solid fills the button, outline outlines it, flat omits the resting border/background, link adds underlined text, and clear uses neutral text. Selected toggles retain a distinct filled state in every mode; Flutter also shows a check mark so custom bold content cannot hide selection, while Blazor adds an inset selected outline. Hover and focus remain separate from selection. Disabled styles indicate non-interactivity. A link fill is visual styling and does not turn a button into a navigation link.

ButtonGroup applies these settings to every item. ItemAppearance/itemAppearance may return NgButtonAppearance with nullable fields; null fields inherit group values. Use this for a command's accent without changing other items. Tokens apply to commands and toggles equally. The Formatting commands and choices demo combines all appearance controls, per-item accents, icons, mixed actions, hidden selection, disabled controls and vertical layout.
"""
for name in ('NgToggleButton','NgButtonGroup'):
    D[name]['notes'] += appearance_notes
D['NgToggleButton']['blazor'] = '''<p id="preview-help">Toggle the preview outline.</p>
<NgToggleButton @ref="toggle" Id="preview-toggle" Label="Preview outline" AriaDescribedBy="preview-help"
    @bind-Value="selected" OnClick="()=>clicks++" Size="lg" Rounded="full" FillMode="outline" ThemeColor="success">
  <Leading><span>★</span></Leading><ChildContent><strong>Preview outline</strong></ChildContent>
</NgToggleButton>
<NgButton OnClick="()=>toggle!.FocusAsync().AsTask()">Focus preview</NgButton>
<p>Selected: @selected. Activations: @clicks</p>
@code { private NgToggleButton? toggle; private bool selected; private int clicks; }
'''
D['NgToggleButton']['dart'] = '''bool selected = false;
int clicks = 0;
final toggleFocus = FocusNode();
@override
void dispose() { toggleFocus.dispose(); super.dispose(); }
Widget build(BuildContext context) => Column(children: [
  NgToggleButton(label: 'Preview outline', semanticIdentifier: 'preview-toggle', semanticHint: 'Toggle the preview outline.',
    value: selected, onChanged: (v) => setState(() => selected = v), onClick: () => setState(() => clicks++),
    focusNode: toggleFocus, size: 'lg', rounded: 'full', fillMode: 'outline', themeColor: 'success',
    leading: const Icon(Icons.star, size: 16), child: const Text('Preview outline')),
  TextButton(onPressed: toggleFocus.requestFocus, child: const Text('Focus preview')),
  Text('Selected: $selected. Activations: $clicks'),
]);
'''
D['NgButtonGroup']['blazor'] = '''<NgCheckBox Label="Hide Emphasis" @bind-Value="hideEmphasis" />
<NgButtonGroup Label="Formatting actions" Items="actions" Value="selected" ValueChanged="Change" Multiple
    IsCommand="IsCommand" IsVisible="ShowItem" OnClick="Activate"
    Size="md" Rounded="lg" FillMode="outline" ItemAppearance="Appearance">
  <LeadingTemplate><span>★</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Label</strong></ItemTemplate>
</NgButtonGroup>
<p>Selected: @string.Join(",",selected). @log</p>
@code {
    private bool hideEmphasis;
    private IReadOnlyList<string> selected = ["strong"];
    private string log = "Ready";
    private readonly NgOption[] actions = [new("strong","Strong"),new("emphasis","Emphasis"),new("clear","Clear formatting")];
    private static bool IsCommand(NgOption item) => item.Value=="clear";
    private bool ShowItem(NgOption item) => !hideEmphasis || item.Value!="emphasis";
    private static NgButtonAppearance Appearance(NgOption item) => new(ThemeColor:IsCommand(item)?"info":null);
    private void Change(IReadOnlyList<string> value) { selected=value; log="changed:"+string.Join(",",value); }
    private void Activate(string id) { log+=" | clicked:"+id; if(id=="clear")selected=[]; }
}
'''
D['NgButtonGroup']['dart'] = '''bool hideEmphasis = false;
List<String> selected = ['strong'];
String log = 'Ready';
final actions = const [NgOption('strong','Strong'),NgOption('emphasis','Emphasis'),NgOption('clear','Clear formatting')];
Widget build(BuildContext context) => Column(children: [
  NgCheckBox(label: 'Hide Emphasis', value: hideEmphasis, onChanged: (v) => setState(() => hideEmphasis=v)),
  NgButtonGroup(label: 'Formatting actions', items: actions, value: selected, multiple: true,
    isCommand: (item) => item.value=='clear', isVisible: (item) => !hideEmphasis || item.value!='emphasis',
    onChanged: (v) => setState(() { selected=v; log='changed:${v.join(",")}'; }),
    onClick: (id) => setState(() { log+=' | clicked:$id'; if(id=='clear')selected=[]; }),
    size: 'md', rounded: 'lg', fillMode: 'outline',
    itemAppearance: (item) => NgButtonAppearance(themeColor: item.value=='clear'?'info':null),
    leadingBuilder: (_) => const Icon(Icons.star, size:16), itemBuilder: (item) => Text(item.label)),
  Text('Selected: ${selected.join(",")}. $log'),
]);
'''

# Navigation block: one source for the reference, code browser and live previews.
D['NgMenu']['notes'] = '''### Commands and data

The parent owns SelectedId/selectedId and dispatches enabled leaf IDs from OnInvoke/onInvoke. Opening a group is not a command. A missing handler disables leaf buttons. Models copy their child collections; replace records to change Visible/visible, Disabled/disabled or Separator/separator. Hidden ancestors suppress their entire subtree. Separators have a unique ID and nonempty descriptive Text/text, never invoke, and cannot have children. Validation includes hidden items: at most 100 unique IDs, three levels, IDs of 1–64 ASCII letters/digits/underscore/hyphen and labels of 1–120 characters.

### Appearance and accessible templates

ItemTemplate/itemBuilder replaces display content; LeadingTemplate/leadingBuilder supplies a decorative icon or image. Text/text remains the accessible name and leading content is excluded from that name. Templates must contain display content only: no buttons, links, inputs or focusable descendants. Automatic URL routing is not provided; handle the leaf callback in the application.

### Opening, closing and direction

CloseOnClick/closeOnClick defaults to true. Set false to keep a menu open after choosing an enabled leaf (for repeated commands). Escape, outside clicks and focus traversal still dismiss. Blazor opens on click or keyboard; Flutter uses Material submenu behavior, including pointer hover. Rtl/rtl reverses horizontal keyboard direction and submenu direction; vertical menus retain Up/Down navigation. Blazor provides one root Tab stop and Home/End; Flutter delegates keyboard handling to Material menus. Removing a focused item is an application-level focus concern. Popup animation, hover delay configuration, arbitrary-model field mapping and full screen-reader certification remain outside this implementation.'''
D['NgMenu']['blazor'] = '''<NgCheckBox Label="Keep menu open" @bind-Value="keepOpen"/>
<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgMenu Label="Document commands" Items="commands" SelectedId="@selected"
        OnInvoke="Run" Rtl="rtl" CloseOnClick="@(!keepOpen)">
  <LeadingTemplate Context="item"><span>◆</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Text</strong></ItemTemplate>
</NgMenu>
<p>Last command: @selected · Invocations: @count</p>
@code {
  private bool keepOpen, rtl;
  private string selected="none"; private int count;
  private readonly NgMenuItem[] commands=[
    new("file","File",children:[new("new","New document"),
      new("exports","Export formats",separator:true),
      new("export","Export",children:[new("pdf","PDF"),new("csv","CSV")]),
      new("secret","Internal command",visible:false),new("delete","Delete",disabled:true)]),
    new("help","Help")];
  private void Run(string id){selected=id;count++;}
}
'''
D['NgMenu']['dart'] = '''bool keepOpen = false, rtl = false; String selected = 'none'; int count = 0;
final commands = [NgMenuItem('file','File',children:[
  NgMenuItem('new','New document'),NgMenuItem('exports','Export formats',separator:true),
  NgMenuItem('export','Export',children:[NgMenuItem('pdf','PDF'),NgMenuItem('csv','CSV')]),
  NgMenuItem('secret','Internal command',visible:false),NgMenuItem('delete','Delete',disabled:true)]),
  NgMenuItem('help','Help')];
Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
  NgCheckBox(label:'Keep menu open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgMenu(label:'Document commands',items:commands,selectedId:selected,rtl:rtl,closeOnClick:!keepOpen,
    leadingBuilder:(_,item)=>const Icon(Icons.description_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.text,style:const TextStyle(fontWeight:FontWeight.bold)),
    onInvoke:(id)=>setState((){selected=id;count++;})),
  Text('Last command: $selected · Invocations: $count'),
]);
'''
D['NgDrawer']['notes'] = '''### State and selection

Expanded/expanded and SelectedId/selectedId belong to the parent. Store callback values and pass them back. An expanded Overlay requires ExpandedChanged/onExpandedChanged so it can be dismissed. CloseOnSelect/closeOnSelect defaults to true: an enabled selection requests the selected ID, then requests collapse in Overlay mode. False keeps the drawer open. Push mode stays expanded after selection. A missing selection callback disables destination buttons. Disabled/disabled blocks the toggle and destination selection but leaves an already-open drawer dismissible through Close, Escape and the backdrop.

### Layout and direction

Overlay/overlay defaults to true. Position/position accepts `start` (default) or `end`, relative to Rtl/rtl (default false): end is right in LTR and left in RTL. Push panels stack above content below 600 px; the position setting applies to wide side-by-side layouts and overlays. Width/width is 200–400 pixels (default 260); overlays clamp to the viewport. The Flutter push panel is 420 pixels tall with a scrolling destination list. Mini mode and swipe gestures are not implemented.

### Templates and data

HeaderTemplate/header replaces the title content while keeping the Close control. FooterTemplate/footer adds content below the list. ItemTemplate/itemBuilder and LeadingTemplate/leadingBuilder customize destination text and decorative icons. Item labels remain accessible names. Item and leading templates must be display-only, without nested interactive controls; keep durable state in the parent, not in templates. Header and footer should be compact so the destination list remains usable.

IsVisible/isVisible filters destinations without deleting the selected ID. IsSeparator/isSeparator renders a divider instead of a destination; it never selects. These predicates must be pure. Replace Items/items when data changes. Up to 100 unique NgOption IDs (1–64 ASCII letters/digits/underscore/hyphen) and nonempty labels (up to 120 characters) are supported, including hidden/separator entries. The application owns routing and permissions. An unknown, hidden or separator SelectedId has no visible selected destination. Full template replacement, arbitrary data-model mapping, automatic URL routing and screen-reader certification remain unimplemented.'''
D['NgDrawer']['blazor'] = '''<NgCheckBox Label="Keep drawer open" @bind-Value="keepOpen"/>
<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgDrawer Label="Workspace navigation" Items="items" @bind-SelectedId="selected"
          @bind-Expanded="expanded" Position="end" Rtl="rtl" CloseOnSelect="@(!keepOpen)"
          IsVisible="ShowItem" IsSeparator="IsDivider">
  <HeaderTemplate><strong>Project workspace</strong></HeaderTemplate>
  <FooterTemplate><small>Signed in as Morgan</small></FooterTemplate>
  <LeadingTemplate Context="item"><span>◆</span></LeadingTemplate>
  <ItemTemplate Context="item"><strong>@item.Label</strong></ItemTemplate>
  <ChildContent><p>Current section: @selected</p><NgTextBox Label="Draft note" @bind-Value="note"/></ChildContent>
</NgDrawer>
@code {
  private bool expanded,keepOpen,rtl; private string? selected="overview",note;
  private readonly NgOption[] items=[new("overview","Overview"),new("divider","Workspace sections"),
    new("reports","Reports"),new("hidden","Internal"),new("locked","Unavailable",true)];
  private bool ShowItem(NgOption item)=>item.Value!="hidden";
  private bool IsDivider(NgOption item)=>item.Value=="divider";
}
'''
D['NgDrawer']['dart'] = '''bool expanded = false, keepOpen = false, rtl = false; String? selected = 'overview';
final note = TextEditingController();
final items = const [NgOption('overview','Overview'),NgOption('divider','Workspace sections'),
  NgOption('reports','Reports'),NgOption('hidden','Internal'),NgOption('locked','Unavailable',disabled:true)];
@override void dispose(){note.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Keep drawer open',value:keepOpen,onChanged:(v)=>setState(()=>keepOpen=v)),
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  NgDrawer(label:'Workspace navigation',items:items,selectedId:selected,
    onSelectedIdChanged:(id)=>setState(()=>selected=id),expanded:expanded,
    onExpandedChanged:(v)=>setState(()=>expanded=v),position:'end',rtl:rtl,closeOnSelect:!keepOpen,
    isVisible:(item)=>item.value!='hidden',isSeparator:(item)=>item.value=='divider',
    header:const Text('Project workspace'),footer:const Text('Signed in as Morgan'),
    leadingBuilder:(_,item)=>const Icon(Icons.folder_outlined,size:18),
    itemBuilder:(_,item)=>Text(item.label,style:const TextStyle(fontWeight:FontWeight.bold)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('Current section: $selected'),NgTextBox(label:'Draft note',controller:note)])),
]);
'''

D['NgStepper']['notes'] = '''### State and display

Value/value is a zero-based, enabled index owned by the parent. ValueChanged/onChanged requests a new index; selecting the current step does nothing. A missing callback or Disabled/disabled disables navigation. Linear/linear defaults to false: when enabled, allow earlier enabled steps or the next enabled step; disabled steps are skipped. Optional and Valid are display metadata, not automatic validation or a skip command. Use 1–30 steps with nonempty labels of at most 120 UTF-16 units.

DisplayMode/displayMode is `all` (default), `labels` or `indicators`. Vertical/vertical controls orientation; horizontal steps wrap. Rtl/rtl defaults to false and mirrors the layout. IndicatorTemplate/indicatorBuilder and LabelTemplate/labelBuilder receive NgStepContext with the step, zero-based index and current-state flag. They replace display content only. Do not put interactive/focusable controls inside either template.

### Accessibility and integration

The accessible name retains the step number, model label, optional and validity state even in indicators-only mode or with custom templates. Blazor exposes aria-current=step; Flutter exposes selected semantics. Every enabled step remains a native Tab stop with Enter/Space activation; arrow-key roving focus and automatic focus movement are not implemented. To reject asynchronous transitions, use Wizard BeforeChange or handle the controlled callback in the application. Replace the item collection when changing metadata. Display mode and templates use an original API; no Telerik theme or declarative-child compatibility is implied.'''
D['NgStepper']['blazor'] = '''<NgCheckBox Label="Right-to-left" @bind-Value="rtl"/>
<NgDropDownList Label="Step display" Items="modes" @bind-Value="mode"/>
<NgStepper Label="Publishing progress" Items="steps" @bind-Value="current" Rtl="rtl" DisplayMode="@mode">
  <IndicatorTemplate Context="step"><span>@(step.Current?"★":"○")</span></IndicatorTemplate>
  <LabelTemplate Context="step"><strong>@step.Step.Label</strong></LabelTemplate>
</NgStepper>
<p>Selected step: @(current+1)</p>
@code {
  private int current; private bool rtl; private string mode="all";
  private readonly NgStep[] steps=[new("Draft",Valid:true),new("Details",Optional:true,Valid:false),new("Publish")];
  private readonly NgOption[] modes=[new("all","Indicators and labels"),new("labels","Labels only"),new("indicators","Indicators only")];
}
'''
D['NgStepper']['dart'] = '''int current = 0; bool rtl = false; String mode = 'all';
final steps = const [NgStep('Draft',valid:true),NgStep('Details',optional:true,valid:false),NgStep('Publish')];
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Right-to-left',value:rtl,onChanged:(v)=>setState(()=>rtl=v)),
  DropdownButtonFormField<String>(initialValue:mode,decoration:const InputDecoration(labelText:'Step display'),
    items:const [DropdownMenuItem(value:'all',child:Text('Indicators and labels')),DropdownMenuItem(value:'labels',child:Text('Labels only')),DropdownMenuItem(value:'indicators',child:Text('Indicators only'))],
    onChanged:(v)=>setState(()=>mode=v!)),
  const SizedBox(height:16),
  NgStepper(label:'Publishing progress',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),rtl:rtl,displayMode:mode,
    indicatorBuilder:(_,step)=>Icon(step.current?Icons.star:Icons.circle_outlined,size:20),
    labelBuilder:(_,step)=>Text(step.step.label,style:const TextStyle(fontWeight:FontWeight.bold))),
  Text('Selected step: ${current+1}'),
]);
'''
D['NgWizard']['notes'] = '''### One transition pipeline

The parent owns Value/value and durable draft data. Linear/linear defaults to true. Header selection, built-in buttons and actions supplied to custom buttons all use the same pipeline: BeforeChange/beforeChange, forward/Finish validation, then ValueChanged/onChanged or OnFinish/onFinish. NgWizardChange contains Current/current, Target/target and IsFinish/isFinish. Return false from the async guard to cancel silently; show any explanation in application-owned UI. Guard exceptions and validation/save exceptions show a generic retry message. Backward movement runs the guard but does not validate. Finish targets the current final enabled step and runs both guard and validation. An empty/null validation message allows continuation.

### Busy, completion and reset

Only one action runs at a time. Successful Finish blocks repeat local submission until reset. Increment ResetKey/resetKey to clear busy/error/completed state even when the current index stays unchanged. Changed index, item metadata, Disabled or Linear also invalidates pending results. A result from an obsolete guard/validator is ignored, including after disposal. This does not cancel your HTTP request, roll back a running save, clear form fields or provide server idempotency: the application owns cancellation, draft reset and safe persistence. Presentation changes alone do not reset completion. Replace collections instead of mutating lists in place.

### Layout and step templates

Position/position accepts `top` (default), `bottom`, `start` or `end`. Side placement is relative to Rtl/rtl and uses a vertical step rail; below 600 px it stacks above the content. Vertical remains available for top/bottom layouts. DisplayMode/displayMode and IndicatorTemplate/indicatorBuilder / LabelTemplate/labelBuilder follow Stepper contracts. Template contexts retain model labels as accessible names. Only active step content is rendered; keep draft controllers/models in the parent. Full content retention and automatic focus movement are not implemented.

### Built-in and custom actions

BackText/backText, NextText/nextText and FinishText/finishText customize built-in captions; each must be nonempty and at most 120 characters. ActionsTemplate/actionsBuilder replaces the action bar and receives NgWizardActions: Value/value, Busy/busy, Finished/finished, IsLast/isLast, CanBack/canBack, CanNext/canNext and CanFinish/canFinish, plus BackAsync/back, NextAsync/next and FinishAsync/finish callbacks. Use IsLast to choose the forward button and Can… to enable it; busy state is not the same as the last step. Await callbacks when handling them yourself. Do not cache the context across renders or bypass it by directly changing Value. The callbacks recheck current navigation, busy, disabled and completion rules. A missing change callback disables navigation, but a single final step can still finish if a finish handler exists.

The English status/error messages are currently built in. Full localization, animated transitions, roving arrow-key focus and complete screen-reader/native-platform validation remain open. Detailed form validation and persistence belong to the application.'''
D['NgWizard']['blazor'] = '''<NgCheckBox Label="Block transitions" @bind-Value="blocked"/>
<NgButton OnClick="Restart">Restart wizard</NgButton>
<NgWizard Label="Application" Items="steps" @bind-Value="current" ResetKey="reset"
          Position="start" BeforeChange="AllowChange" ValidateStep="Validate" OnFinish="Save">
  <IndicatorTemplate Context="step"><span>@(step.Index==0?"✎":"✓")</span></IndicatorTemplate>
  <ChildContent Context="index">
    @if(index==0){<NgTextBox Label="Applicant name" @bind-Value="name"/>}
    else{<p>Review: @name</p>}
  </ChildContent>
  <ActionsTemplate Context="actions">
    <div class="ng-wizard-actions">
      <NgButton Disabled="@(!actions.CanBack)" OnClick="actions.BackAsync">Previous</NgButton>
      @if(!actions.IsLast){<NgButton Primary Disabled="@(!actions.CanNext)" OnClick="actions.NextAsync">Continue</NgButton>}
      else{<NgButton Primary Disabled="@(!actions.CanFinish)" OnClick="actions.FinishAsync">Save application</NgButton>}
    </div>
  </ActionsTemplate>
</NgWizard>
<p>@status</p>
@code {
  private int current,reset; private bool blocked; private string? name;
  private string status="Not saved";
  private readonly NgStep[] steps=[new("Contact"),new("Review")];
  private Task<bool> AllowChange(NgWizardChange change)=>Task.FromResult(!blocked);
  private Task<string?> Validate(int index)=>Task.FromResult<string?>(index==0&&string.IsNullOrWhiteSpace(name)?"Enter your name.":null);
  private Task Save(){status="Saved locally";return Task.CompletedTask;}
  private void Restart(){reset++;current=0;status="Not saved";}
}
'''
D['NgWizard']['dart'] = '''int current = 0, reset = 0; bool blocked = false; String status = 'Not saved';
final name = TextEditingController(); final steps = const [NgStep('Contact'),NgStep('Review')];
@override void dispose(){name.dispose();super.dispose();}
Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  NgCheckBox(label:'Block transitions',value:blocked,onChanged:(v)=>setState(()=>blocked=v)),
  NgButton(onPressed:()=>setState((){reset++;current=0;status='Not saved';}),child:const Text('Restart wizard')),
  NgWizard(label:'Application',items:steps,value:current,onChanged:(v)=>setState(()=>current=v),resetKey:reset,
    position:'start',beforeChange:(change)async=>!blocked,
    validateStep:(index)async=>index==0&&name.text.trim().isEmpty?'Enter your name.':null,
    onFinish:()async{setState(()=>status='Saved locally');},
    indicatorBuilder:(_,step)=>Icon(step.index==0?Icons.person_outline:Icons.check,size:20),
    contentBuilder:(_,index)=>index==0?NgTextBox(label:'Applicant name',controller:name):Text('Review: ${name.text}'),
    actionsBuilder:(_,a)=>Wrap(spacing:16,runSpacing:8,children:[
      NgButton(onPressed:a.canBack?a.back:null,child:const Text('Previous')),
      if(!a.isLast)NgButton(primary:true,onPressed:a.canNext?a.next:null,child:const Text('Continue'))
      else NgButton(primary:true,onPressed:a.canFinish?a.finish:null,child:const Text('Save application'))])),
  Text(status),
]);
'''

# Text editor and form workbench, 0.29.
D['NgTextBox']['notes'] = '### Editing and ownership\nBlazor uses @bind-Value and InputBase/EditContext validation. Flutter uses an application-owned TextEditingController or initialValue, never both; initialValue is not a continuously controlled value. Dispose controllers and FocusNodes in their owner. Programmatic controller changes do not invoke onChanged.\n\nReadOnly/readOnly permits focus, selection and copying without editing. Disabled/enabled=false prevents normal interaction. Placeholder is a hint, not a replacement for the visible label. HelperText/helperText is persistent guidance. Blazor merges its helper ID with caller-supplied aria-describedby.\n\nPrefixTemplate/SuffixTemplate and prefix/suffix accept decorative content beside the editor. Keep decoration short; provide separate labelled controls for interactive actions. These slots do not replace the field label or validator. Use FocusAsync after rendering in Blazor, or an owned focusNode.requestFocus() in Flutter.\n\nMaxLength must be positive when supplied. It limits user entry, not application data: validate on the server too. Browser maxlength counts UTF-16 units; Flutter counts grapheme clusters and displays its native counter. Emoji limits can therefore differ. Existing/programmatic overlong values are not silently truncated. \n\nOnCommit is the Blazor native change event (normally blur, or Enter for a single-line input); ValueChanged still fires while typing. Flutter onSubmitted is the platform submission action, not a blur event; multiline Enter normally inserts a newline. These are deliberately documented platform contracts, not identical event timing.\n\n### Current scope\nNo debounce, automatic resize, password mode, automatic clear button, full appearance variants or certified screen-reader parity. Native/mobile verification remains deferred. Application supplies localized labels, guidance and validation errors.'
D['NgTextBox']['blazor'] = '<NgCheckBox Label="Read only" @bind-Value="locked"/>\n<NgTextBox @ref="editor" Label="Project name" @bind-Value="text" ReadOnly="locked" MaxLength="80" HelperText="Use a short, descriptive name." OnCommit="v=>committed=v">\n<PrefixTemplate><span aria-hidden="true">@</span></PrefixTemplate>\n</NgTextBox>\n<NgButton OnClick="()=>editor!.FocusAsync().AsTask()">Focus editor</NgButton>\n<p>Current: @text</p><p>Committed: @committed</p>\n@code { private NgTextBox? editor; private bool locked; private string? text="Design review",committed; }\n'
D['NgTextBox']['dart'] = "bool locked = false; String submitted = '';\nfinal editor = TextEditingController(text:'Design review');\nfinal focus = FocusNode();\n@override void dispose(){editor.dispose();focus.dispose();super.dispose();}\nWidget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\nNgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),\nNgTextBox(label:'Project name',controller:editor,focusNode:focus,readOnly:locked,maxLength:80,\nhelperText:'Use a short, descriptive name.',prefix:const Icon(Icons.edit_outlined),\nonChanged:(_)=>setState((){}),onSubmitted:(v)=>setState(()=>submitted=v)),\nNgButton(onPressed:()=>focus.requestFocus(),child:const Text('Focus editor')),\nText('Current: ${editor.text}'),Text('Submitted: $submitted')]);\n"
D['NgTextArea']['notes'] = '### Editing and ownership\nBlazor uses @bind-Value and InputBase/EditContext validation. Flutter uses an application-owned TextEditingController or initialValue, never both; initialValue is not a continuously controlled value. Dispose controllers and FocusNodes in their owner. Programmatic controller changes do not invoke onChanged.\n\nReadOnly/readOnly permits focus, selection and copying without editing. Disabled/enabled=false prevents normal interaction. Placeholder is a hint, not a replacement for the visible label. HelperText/helperText is persistent guidance. Blazor merges its helper ID with caller-supplied aria-describedby.\n\nPrefixTemplate/SuffixTemplate and prefix/suffix accept decorative content beside the editor. Keep decoration short; provide separate labelled controls for interactive actions. These slots do not replace the field label or validator. Use FocusAsync after rendering in Blazor, or an owned focusNode.requestFocus() in Flutter.\n\nMaxLength must be positive when supplied. It limits user entry, not application data: validate on the server too. Browser maxlength counts UTF-16 units; Flutter counts grapheme clusters and displays its native counter. Emoji limits can therefore differ. Existing/programmatic overlong values are not silently truncated. Rows must be 1–30; this is a fixed-row editor, not automatic resizing. \n\nOnCommit is the Blazor native change event (normally blur, or Enter for a single-line input); ValueChanged still fires while typing. Flutter onSubmitted is the platform submission action, not a blur event; multiline Enter normally inserts a newline. These are deliberately documented platform contracts, not identical event timing.\n\n### Current scope\nNo debounce, automatic resize, password mode, automatic clear button, full appearance variants or certified screen-reader parity. Native/mobile verification remains deferred. Application supplies localized labels, guidance and validation errors.'
D['NgTextArea']['blazor'] = '<NgCheckBox Label="Read only" @bind-Value="locked"/>\n<NgTextArea @ref="editor" Label="Delivery notes" @bind-Value="text" ReadOnly="locked" MaxLength="80" HelperText="Use a short, descriptive note." OnCommit="v=>committed=v">\n<PrefixTemplate><span aria-hidden="true">✎</span></PrefixTemplate>\n</NgTextArea>\n<NgButton OnClick="()=>editor!.FocusAsync().AsTask()">Focus editor</NgButton>\n<p>Current: @text</p><p>Committed: @committed</p>\n@code { private NgTextArea? editor; private bool locked; private string? text="Design review",committed; }\n'
D['NgTextArea']['dart'] = "bool locked = false; String submitted = '';\nfinal editor = TextEditingController(text:'Design review');\nfinal focus = FocusNode();\n@override void dispose(){editor.dispose();focus.dispose();super.dispose();}\nWidget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\nNgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),\nNgTextArea(label:'Delivery notes',controller:editor,focusNode:focus,readOnly:locked,maxLength:80,\nhelperText:'Use a short, descriptive note.',prefix:const Icon(Icons.edit_outlined),\nonChanged:(_)=>setState((){}),onSubmitted:(v)=>setState(()=>submitted=v)),\nNgButton(onPressed:()=>focus.requestFocus(),child:const Text('Focus editor')),\nText('Current: ${editor.text}'),Text('Submitted: $submitted')]);\n"
D['NgForm']['notes'] = '### Validation and asynchronous saving\nBlazor wraps EditForm/DataAnnotationsValidator; place a Type="submit" button inside ChildContent. Flutter wraps Form, runs every registered validator and supplies its own submit button. Do not nest forms. ShowSummary/showSummary controls the summary, not field-level validation. OnInvalidSubmit/onInvalidSubmit reports failed validation; persistence runs only when all fields pass.\n\nOnValidSubmit/onValidSubmit may be asynchronous. While it is pending, further submissions are ignored and content interaction is blocked. Blazor uses a disabled fieldset; Flutter blocks pointer/focus interaction. Custom overlays and programmatic callbacks still belong to the application. Disabled/enabled=false also blocks submissions. BusyText/busyText and ErrorText/errorText can be localized. A thrown save exception shows the generic configured error and enables retry; the component does not expose exception details.\n\n### Reset and persistence boundaries\nThe application owns the model, transport and persisted result. To reset draft state, touched fields and validation, replace both the model and the component key (Blazor @key, Flutter Key); external Flutter formKey must also be new. Disposed forms ignore late local state updates. Reset does not cancel transport or undo a save already accepted by the server. Snapshot the submitted values and use backend idempotency for important operations. A completed submission does not permanently lock the form: a later explicit submit may save again.\n\nAutomatic model-driven editor generation, conditional schemas, custom summary templates, field grids and full Telerik event/API compatibility remain unimplemented. This block is Web-only verification.'
D['NgForm']['blazor'] = '<NgCheckBox Label="Simulate save failure" @bind-Value="fail"/>\n<NgForm @key="model" Model="model" OnValidSubmit="Save">\n<NgTextBox Label="Application name" @bind-Value="model.Name" MaxLength="80" HelperText="Required before saving."/>\n<NgTextArea Label="Notes" @bind-Value="model.Notes" Rows="3" MaxLength="200"/>\n<NgButton Type="submit" Primary>Save application</NgButton>\n</NgForm>\n<NgButton OnClick="()=>{model=new();status="Not saved";}">Reset application</NgButton>\n<p role="status">@status</p>\n@code {\n private Draft model=new(); private bool fail; private string status="Not saved";\n private async Task Save(){var draft=model;var denied=fail;var name=draft.Name;await Task.Delay(1000);if(denied)throw new InvalidOperationException();if(ReferenceEquals(model,draft))status=$"Saved: {name}";}\n public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Name{get;set;} public string? Notes{get;set;}}\n}\n'
D['NgForm']['dart'] = "int revision = 0; bool fail = false; String name = '', notes = '', status = 'Not saved';\nWidget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[\nNgCheckBox(label:'Simulate save failure',value:fail,onChanged:(v)=>setState(()=>fail=v)),\nNgForm(key:ValueKey(revision),submitLabel:'Save application',onValidSubmit:()async{\nfinal version=revision,denied=fail;final snapshot=name;\nawait Future<void>.delayed(const Duration(seconds:1));\nif(denied)throw StateError('Demo failure');\nif(mounted&&version==revision)setState(()=>status='Saved: $snapshot');\n},child:Column(children:[\nNgTextBox(label:'Application name',initialValue:name,maxLength:80,helperText:'Required before saving.',onChanged:(v)=>name=v,validator:(v)=>v==null||v.trim().isEmpty?'Enter an application name.':null),\nNgTextArea(label:'Notes',initialValue:notes,rows:3,maxLength:200,onChanged:(v)=>notes=v)])),\nNgButton(onPressed:()=>setState((){revision++;name='';notes='';status='Not saved';}),child:const Text('Reset application')),\nText(status)]);\n"
D['NgTextBox']['blazor'] = D['NgTextBox']['blazor'].replace('>@</span>', '>@@</span>')
D['NgForm']['blazor'] = D['NgForm']['blazor'].replace('OnClick="()=>{model=new();status="Not saved";}"', 'OnClick="Reset"').replace(' private async Task Save()', ' private void Reset(){model=new();status="Not saved";}\n private async Task Save()')
for _editor in ('NgTextBox','NgTextArea'):
    D[_editor]['notes'] = '\n'.join(line.rstrip() for line in D[_editor]['notes'].splitlines())

# Local selection input workbench, 0.30.
D['NgAutoComplete']['notes'] = '''### Free text and filtering
AutoComplete accepts free text; choosing a suggestion is optional. Blazor uses @bind-Value. Flutter initialValue is a starting draft, not a controlled value; use a new key for a wholesale reset. onChanged reports typing and accepted suggestions. Application validation and persistence remain separate.

FilterMode/filterMode accepts contains, startsWith or endsWith (case-insensitive). MinLength/minLength must be nonnegative; default 1 hides suggestions for empty input. Placeholder is guidance, not an accessible label. ReadOnly/readOnly blocks editing and selection; Disabled/enabled=false blocks normal interaction.

### Native popup differences
Blazor retains the browser datalist. The supplied options are prefiltered, and Chrome may apply its own additional matching/display behavior. Flutter uses Material Autocomplete and an owned controller/focus node. Suggestion presentation, opening and keyboard behavior remain framework-native. Replace item lists when updating data; type again to refresh an already-open Flutter suggestion list.

No remote async loading, debounce, virtualization, item/header/footer templates, clear action, custom popup API or full screen-reader certification is supplied. Filtering is not locale-aware collation; case folding can differ for non-ASCII strings. Web is the verified platform target.'''
D['NgAutoComplete']['blazor'] = '''<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgAutoComplete Label="City" Items="cities" @bind-Value="city" FilterMode="startsWith" MinLength="2" ReadOnly="locked" Placeholder="Type at least two letters"/>
<p>Current city: @city</p>
@code { private bool locked;private string? city;private readonly string[] cities=["London","Lisbon","Los Angeles","Berlin"]; }
'''
D['NgAutoComplete']['dart'] = '''bool locked=false;String city='';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgAutoComplete(label:'City',items:const ['London','Lisbon','Los Angeles','Berlin'],filterMode:'startsWith',minLength:2,readOnly:locked,placeholder:'Type at least two letters',onChanged:(v)=>setState(()=>city=v)),
Text('Current city: $city')]);
'''
D['NgComboBox']['notes'] = '''### IDs, drafts and validation
Value/value is an option ID, never its display label. Items need unique nonempty IDs and nonempty labels. Replace item collections to publish changes. Renaming the selected item updates its visible label without changing the ID. When the selected item disappears, the editor becomes empty while the parent still owns the old ID: clear or replace that ID in your application. In Flutter, replace the component key to discard an unrelated invalid draft; initial draft state otherwise remains local.

Typing a case-insensitive exact enabled label selects its ID; duplicate labels resolve to the first enabled match. Arbitrary text stays visible and blocks validation without replacing the last valid model ID. Clearing emits null. Disabled items cannot be selected. Use @bind-Value and model annotations in Blazor; required and NgForm/Form in Flutter. Never persist an old ID merely because the draft is invalid: validate the enclosing form first.

### Filtering and presentation
FilterMode/filterMode is contains, startsWith or endsWith; MinLength/minLength defaults to 0. A positive minimum hides suggestions until enough text is entered. Placeholder labels empty input. ReadOnly/readOnly blocks typing, selection and clear while allowing inspection. ShowClearButton/showClearButton exposes a labelled clear action. The application owns any required-value error after clearing.

ItemTemplate/itemBuilder decorates an option; its accessible name remains NgOption.Label. Keep templates noninteractive. Blazor EmptyText customizes the empty popup message. Flutter RawAutocomplete closes an empty popup; there is no equivalent empty popup template. Blazor shows disabled matches; Flutter omits them. Native keyboard navigation and popup positioning differ; Flutter active options now have a visible highlight.

### Remaining scope
No remote loading, virtualization, custom values, arbitrary model adapter, debounce, full popup header/footer templates or appearance variants. A parent data refresh can replace the displayed draft; preserve application drafts separately when needed. Web checks do not certify native/mobile or screen-reader parity.'''
D['NgComboBox']['blazor'] = '''<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgForm Model="model" OnValidSubmit="()=>status=$\"Saved ID: {model.Person}\"">
<NgComboBox Label="Assignee" Items="people" @bind-Value="model.Person" ReadOnly="locked" ShowClearButton FilterMode="startsWith" MinLength="1" Placeholder="Search a person">
<ItemTemplate Context="person"><strong>@person.Label</strong><small> · Team member</small></ItemTemplate>
</NgComboBox>
<NgButton Type="submit" Primary>Save selection</NgButton>
</NgForm>
<NgButton OnClick="Rename">Rename selected</NgButton><p>@status</p>
@code {
 private bool locked;private string status="Not saved";private Draft model=new();
 private NgOption[] people=[new("a","Alex"),new("b","Bella"),new("x","Blocked",true)];
 private void Rename(){people=people.Select(p=>p.Value==model.Person?p with{Label="Alex Morgan"}:p).ToArray();}
 public class Draft{[System.ComponentModel.DataAnnotations.Required] public string? Person{get;set;}="a";}
}
'''
# Keep Razor callback in a named method so the runnable example is easy to copy.
D['NgComboBox']['blazor'] = D['NgComboBox']['blazor'].replace('OnValidSubmit="()=>status=$"Saved ID: {model.Person}""','OnValidSubmit="Save"').replace(' private void Rename()', ' private void Save()=>status=$"Saved ID: {model.Person}";\n private void Rename()')
D['NgComboBox']['dart'] = '''bool locked=false;String? person='a';String status='Not saved';
List<NgOption> people=[const NgOption('a','Alex'),const NgOption('b','Bella'),const NgOption('x','Blocked',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgForm(submitLabel:'Save selection',onValidSubmit:()=>setState(()=>status='Saved ID: $person'),child:
NgComboBox(label:'Assignee',value:person,items:people,required:true,readOnly:locked,showClearButton:true,filterMode:'startsWith',minLength:1,placeholder:'Search a person',onChanged:(v)=>setState(()=>person=v),itemBuilder:(_,o)=>Text('${o.label} · Team member'))),
NgButton(onPressed:()=>setState(()=>people=people.map((o)=>o.value==person?NgOption(o.value,'Alex Morgan'):o).toList()),child:const Text('Rename selected')),
Text(status)]);
'''
D['NgMultiSelect']['notes'] = '''### Controlled selection
Value/value is an array/list of option IDs. Items require unique nonempty IDs and nonempty labels. The parent stores emitted copies and passes them back; never mutate an emitted list or source collection in place. Flutter validation reads the current controlled value, including parent-driven changes. In Blazor use model data annotations for required/minimum selection; Flutter exposes required. MaxSelected/maxSelected must be positive if supplied and limits user additions, not externally supplied values.

Disabled options are locked: they cannot be added, removed through a chip, or cleared by bulk actions. An already-selected disabled ID counts toward the limit. Unknown selected IDs are shown as their raw ID and can be removed; the application decides how to reconcile removed records. ReadOnly/readOnly freezes selection while still allowing the list to be filtered. Disabled/enabled=false also disables filtering.

### Search, templates and bulk actions
FilterMode/filterMode accepts contains, startsWith or endsWith; MinLength/minLength defaults to 0. Placeholder and EmptyText/emptyText customize search and no-match guidance. Filtering never removes selections. ItemTemplate/itemBuilder and TagTemplate/tagBuilder decorate list items and selected chips while retaining accessible model labels. Use short noninteractive content.

ShowActions/showActions adds Select filtered and Clear selection. Select filtered takes every enabled match plus the existing selection, preserving order and removing duplicates. If the combined selection exceeds MaxSelected, the entire action is rejected with a message: no partial selection. Clear selection removes every unlocked selection, including those hidden by the filter, and retains disabled selections. These bulk actions are original Nextgen behavior, not a claim of Telerik API compatibility.

### Remaining scope
This implementation is an inline checklist with selected chips, not a popup MultiSelect. Remote data, virtualization, grouping, custom values, summary tags, popup timing/close behavior, localization of every action/status, complete keyboard-focus management and screen-reader/native certification remain open. Case folding follows each platform, not culture-specific collation.'''
D['NgMultiSelect']['blazor'] = '''<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgMultiSelect Label="Services" Items="services" @bind-Value="selected" MaxSelected="3" ShowActions ReadOnly="locked" EmptyText="No matching services">
<ItemTemplate Context="service"><strong>@service.Label</strong><small> · service</small></ItemTemplate>
<TagTemplate Context="service"><span>✓ @service.Label</span></TagTemplate>
</NgMultiSelect>
<p>Selected IDs: @string.Join(", ",selected)</p>
@code {private bool locked;private string[] selected=["locked"];private readonly NgOption[] services=[new("a","Alpha"),new("b","Beta"),new("g","Gamma"),new("locked","Mandatory",true)];}
'''
D['NgMultiSelect']['dart'] = '''bool locked=false;List<String> selected=['locked'];
final services=const [NgOption('a','Alpha'),NgOption('b','Beta'),NgOption('g','Gamma'),NgOption('locked','Mandatory',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
NgMultiSelect(label:'Services',value:selected,items:services,maxSelected:3,showActions:true,readOnly:locked,emptyText:'No matching services',onChanged:(v)=>setState(()=>selected=v),itemBuilder:(_,o)=>Text('${o.label} · service'),tagBuilder:(_,o)=>Text('✓ ${o.label}')),
Text('Selected IDs: ${selected.join(', ')}')]);
'''

D['NgComboBox']['notes'] += '\n\nFlutter caches the currently computed popup options until the next text edit. After replacing Items or filter configuration, edit the query to recompute suggestions. A stale callback for a removed, renamed or newly disabled option is rejected against the current collection.'


# Numeric and time editing block, 0.31.
D['NgNumericTextBox'].update(use='Edit bounded numbers with explicit increment controls, retained invalid drafts and read-only review.',
notes="""Value/value is nullable and controlled by the parent. Blazor uses decimal; Flutter uses finite double, so binary floating-point rounding can appear. Use a dot decimal separator and optional leading sign. Grouping separators, exponent notation, NaN and infinity are rejected. Empty input emits null (Flutter required can reject it; Blazor use model validation attributes).

Min/min and Max/max are inclusive edit constraints. Invalid or out-of-range drafts remain visible, do not replace the last valid model and block form validation. Bounds must be ordered; Step/step must be positive (and finite in Flutter). These constraints validate user edits, not arbitrary values supplied by the parent; validate application models independently.

ShowSpinButtons/showSpinButtons defaults to true. Increase and Decrease add/subtract Step from the last valid model, using zero for null, then clamp to bounds. A spin deliberately replaces an invalid draft. Step does not restrict typed decimal precision or require multiples. Blazor also handles ArrowUp/ArrowDown; Flutter exposes labelled focusable buttons. Native browser number controls are replaced by a text editor so invalid drafts are preserved consistently.

ReadOnly/readOnly permits copying but blocks editing and spin actions; Disabled/enabled=false blocks interaction. Missing change callbacks disable spin buttons. HelperText/helperText explains the field. Flutter replaces the draft when the parent supplies a changed value. In Blazor, InputBase retains parsing-failed text until correction. Use a new component key to discard an invalid draft reliably on either platform.

Currency/percent formats, custom culture, precision rounding, acceleration and full screen-reader certification remain out of scope.""",
blazor='''<NgForm Model="model" OnValidSubmit="Save">
<NgNumericTextBox Label="Amount" @bind-Value="model.Amount" Min="0" Max="10" Step="0.5m" ReadOnly="readOnly" HelperText="0 to 10; buttons change by 0.5." />
<NgButton Type="submit" Primary>Save amount</NgButton>
</NgForm>
<NgButton OnClick="Toggle">Read only</NgButton>
<p>Accepted amount: @model.Amount</p><p>@status</p>
@code {
 private Draft model=new(); private bool readOnly; private string status="";
 private void Toggle()=>readOnly=!readOnly;
 private void Save()=>status="Saved amount: "+model.Amount;
 private sealed class Draft { public decimal? Amount {get;set;}=2; }
}''',
dart='''double? amount=2; bool readOnly=false; String status='';
@override
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 NgForm(submitLabel:'Save amount',onValidSubmit:()=>setState(()=>status='Saved amount: $amount'),child:
  NgNumericTextBox(label:'Amount',value:amount,min:0,max:10,step:0.5,readOnly:readOnly,
   helperText:'0 to 10; buttons change by 0.5.',onChanged:(v)=>setState(()=>amount=v))),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted amount: $amount'),Text(status),
]);''')
for _name in ['NgTimePicker','NgDateTimePicker']:
 D[_name]['notes'] += """

MinuteStep/minuteStep defaults to 1. Set 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30 or 60: the step must divide an hour. Accepted minutes are multiples from the start of each hour, independently of Min. Bounds are inclusive and must be ordered. For example, with 15-minute intervals, 09:15 is accepted and 09:17 remains an invalid draft. Typed invalid drafts do not replace the last valid model and block form submission. These rules validate edits; externally supplied model values must be validated by the application.

ReadOnly/readOnly blocks typing and picker changes while keeping the value readable. Blazor retains the browser-native picker with unrestricted native stepping; the component validates the chosen result. Flutter's Material time dialog still displays all minutes and rejects an off-step selection with a message. This is interval validation, not a restricted-minute popup. A stale Flutter dialog result is discarded after editor changes, parent rebuild or disposal. Reset with a new key if the parent value is unchanged.

Custom display formats, time zones, disabled time lists and popup templates remain gaps. No implicit UTC conversion occurs; values represent local wall-clock time."""
 D[_name]['blazor']=D[_name]['blazor'].replace('Label="Date"', 'Label="Appointment" MinuteStep="15"')
 D[_name]['dart']=D[_name]['dart'].replace('(value: value,', "(label: 'Appointment', minuteStep: 15, value: value,")

# Calendar/date editing block: executable, bounded and read-only examples.
for _name in ['NgDateInput', 'NgDatePicker', 'NgCalendar', 'NgDateRangePicker']:
 D[_name]['notes'] += """

ReadOnly/readOnly prevents user changes. Disabled/enabled also disables interaction. Date editors keep readable, focusable text in read-only mode and disable their picker action; Calendar blocks selection and navigation (Flutter also excludes keyboard focus). Bounds must be ordered; invalid configuration throws. Values are Gregorian calendar dates; date text is ISO yyyy-MM-dd, independent of Blazor's current culture. Empty optional input clears to null.

DisabledDate/disabledDate applies to typing and calendar selection. In a range it checks both endpoints, not every date between them. Partial and reversed ranges fail form validation. Flutter range validation reads the current parent value after replacement. Applications own validation of external single-date values. Replace the form key to discard an invalid draft when the model value is unchanged.

Flutter calendars use Material locale/week-start and default bounds 1900–2100; Blazor uses Culture/FirstDayOfWeek and DateOnly bounds. Supply explicit bounds for matching domains. Calendar selection is single-date only. Shared range highlighting, multiple calendar views, cell templates, week numbers, segmented/custom-format input and complete keyboard/screen-reader parity remain open. Flutter popup results are ignored after a parent rebuild, edit or disposal."""
 if _name != 'NgDateRangePicker':
  D[_name]['blazor'] = f'''<{_name} @bind-Value="value" Min="min" Max="max" DisabledDate="Unavailable" ReadOnly="readOnly" />
<NgButton OnClick="Toggle">Read only</NgButton>
<p>Accepted date: @value</p>
@code {{
 private DateOnly? value=new(2026,10,20); private bool readOnly;
 private DateOnly min=new(2026,10,1), max=new(2026,10,31);
 private bool Unavailable(DateOnly d)=>d.DayOfWeek==DayOfWeek.Sunday;
 private void Toggle()=>readOnly=!readOnly;
}}'''
  D[_name]['dart'] = f'''DateTime? value=DateTime(2026,10,20); bool readOnly=false;
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
 {_name}(value:value,min:DateTime(2026,10,1),max:DateTime(2026,10,31),
  readOnly:readOnly,disabledDate:(d)=>d.weekday==DateTime.sunday,
  onChanged:(v)=>setState(()=>value=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Accepted date: $value'),
]);'''
 else:
  D[_name]['blazor']=D[_name]['blazor'].replace('Label="Period"', 'Label="Period" DisabledDate="d => d.DayOfWeek == DayOfWeek.Sunday"')
  D[_name]['dart']=D[_name]['dart'].replace('required: true,', 'disabledDate: (d) => d.weekday == DateTime.sunday, required: true,')

D['NgDropDownList'].update(
blazor='''<NgForm Model="model" OnValidSubmit="Save">
 <NgDropDownList Label="Team" @bind-Value="model.Team" Items="items" ReadOnly="readOnly" Placeholder="Choose a team" HelperText="Unavailable selections must be replaced." />
 <NgButton Type="submit">Save team</NgButton>
</NgForm>
<NgButton OnClick="Remove">Remove selected option</NgButton>
<NgButton OnClick="Toggle">Read only</NgButton>
<p>Selected team: @model.Team</p><p>@status</p>
@code {
 private Draft model=new(); private bool readOnly; private string status="";
 private NgOption[] items=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)];
 private void Remove()=>items=items.Where(o=>o.Value!=model.Team).ToArray();
 private void Toggle()=>readOnly=!readOnly;
 private void Save()=>status="Saved team: "+model.Team;
 private sealed class Draft { public string Team {get;set;}="design"; }
}''',
dart='''String? team='design'; bool readOnly=false; String status='';
List<NgOption> items=[const NgOption('design','Design'),const NgOption('dev','Engineering'),const NgOption('locked','Unavailable',disabled:true)];
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgForm(submitLabel:'Save team',onValidSubmit:()=>setState(()=>status='Saved team: $team'),child:
  NgDropDownList(label:'Team',value:team,items:items,readOnly:readOnly,placeholder:'Choose a team',helperText:'Unavailable selections must be replaced.',onChanged:(v)=>setState(()=>team=v))),
 NgButton(onPressed:()=>setState(()=>items=items.where((o)=>o.value!=team).toList()),child:const Text('Remove selected option')),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 Text('Selected team: $team'),Text(status),
]);''')
D['NgRadioGroup'].update(
blazor='''<NgRadioGroup Label="Team" Items="items" @bind-Value="team" ReadOnly="readOnly" Orientation="@orientation" HelperText="Choose one available team.">
 <ItemTemplate Context="item"><strong>Team · @item.Label</strong></ItemTemplate>
</NgRadioGroup>
<NgButton OnClick="Toggle">Read only</NgButton>
<NgButton OnClick="Layout">Change layout</NgButton>
<p>Selected team: @team</p>
@code {
 private string team="design",orientation="vertical"; private bool readOnly;
 private NgOption[] items=[new("design","Design"),new("dev","Engineering"),new("locked","Unavailable",true)];
 private void Toggle()=>readOnly=!readOnly;
 private void Layout()=>orientation=orientation=="vertical"?"horizontal":"vertical";
}''',
dart='''String? team='design'; bool readOnly=false; String orientation='vertical';
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 NgRadioGroup(label:'Team',value:team,orientation:orientation,readOnly:readOnly,helperText:'Choose one available team.',
  items:const[NgOption('design','Design'),NgOption('dev','Engineering'),NgOption('locked','Unavailable',disabled:true)],
  itemBuilder:(_,o)=>Text('Team · ${o.label}',style:const TextStyle(fontWeight:FontWeight.bold)),onChanged:(v)=>setState(()=>team=v)),
 NgButton(onPressed:()=>setState(()=>readOnly=!readOnly),child:const Text('Read only')),
 NgButton(onPressed:()=>setState(()=>orientation=orientation=='vertical'?'horizontal':'vertical'),child:const Text('Change layout')),
 Text('Selected team: $team'),
]);''')
for _name in ['NgRadioGroup','NgDropDownList']:
 D[_name]['notes'] += """

ReadOnly/readOnly and Disabled/enabled prevent user selection. These native choice controls use disabled interaction in read-only mode and do not promise focusable read-only text. HelperText/helperText adds visible guidance. IDs and labels must be nonempty and IDs unique; invalid option configuration throws. Selected disabled items can remain visible but cannot be chosen by user action. Removing a selected key never selects another option implicitly.

RadioGroup Orientation/orientation accepts horizontal (existing default) or vertical. ItemTemplate/itemBuilder customizes decorative content; the option label remains the accessible name. Do not put interactive controls inside the item template. Flutter label taps and native radio selection obey the same disabled/read-only rules. RadioGroup external missing keys and required rules remain application-owned; it is not a standalone Flutter FormField.

DropDownList preserves an unknown selected key as an unavailable entry and rejects form submission until it is replaced or cleared by the application. Blazor supports an empty placeholder option; Flutter placeholder is a hint for null and does not add a clear command. A stale Flutter popup result after a parent rebuild is ignored. Placeholder is not required validation: use model annotations on Blazor and validator on Flutter. Text filtering, remote loading, virtualization, grouping and custom popup templates remain open; use ComboBox for searchable input."""


# Text clear actions and password presentation, 0.46.
for _editor in ('NgTextBox','NgTextArea'):
    D[_editor]['blazor'] = D[_editor]['blazor'].replace('ReadOnly="locked"', 'ReadOnly="locked" ShowClearButton="true"')
    D[_editor]['dart'] = D[_editor]['dart'].replace('readOnly:locked,', 'readOnly:locked,showClearButton:true,')
    D[_editor]['notes'] = D[_editor]['notes'].replace('password mode, automatic clear button, ', '')
    D[_editor]['notes'] += '\n\n### Clear action (0.46)\nShowClearButton/showClearButton adds a labelled Clear action. It is disabled for empty, read-only or disabled fields. Clear sets the value to the empty string, not null, updates the form field and emits one value-change callback. It restores input focus and does not explicitly invoke OnCommit/onSubmitted; Blazor native blur/change can still commit the preceding typed value when focus moves to the button. Required validators can therefore reject the empty field. Flutter preserves controller ownership and initialValue form reset; retained actions cannot clear a replacement controller or bypass locks. The clear action and supplied suffix can coexist.\n'
D['NgTextBox']['blazor'] = D['NgTextBox']['blazor'].replace('<NgCheckBox Label="Read only"', '<NgButton OnClick="()=>password=!password">Toggle password mode</NgButton>\n<NgCheckBox Label="Read only"',1).replace('ShowClearButton="true"','ShowClearButton="true" Password="password" ShowPasswordToggle="true"').replace('<p>Current: @text</p><p>Committed: @committed</p>', '<p>Length: @(text?.Length??0)</p>').replace('private bool locked;', 'private bool locked,password=true;')
D['NgTextBox']['dart'] = D['NgTextBox']['dart'].replace('bool locked = false;', 'bool locked = false, password = true;').replace('children:[', "children:[\nNgButton(onPressed:()=>setState(()=>password=!password),child:const Text('Toggle password mode')),",1).replace('showClearButton:true,','showClearButton:true,password:password,showPasswordToggle:true,').replace("Text('Current: ${editor.text}'),Text('Submitted: $submitted')", "Text('Length: ${editor.text.length}')")
D['NgTextBox']['notes'] += '\n### Password presentation\nPassword/password masks the single-line value; default false. ShowPasswordToggle/showPasswordToggle is opt-in and only appears in password mode. Reveal changes presentation, never the bound value or change callbacks. Read-only/disabled fields cannot reveal; entering these states hides the value. Clear and focus leaving the reveal control hide it too. Flutter controller replacement resets reveal. Password mode does not encrypt values or provide a credential manager; application storage and submission remain application responsibilities. Flutter disables suggestions/autocorrection in password mode. TextArea has no password mode.\n'


# Bounded automatic TextArea height, 0.47.
D['NgTextArea']['notes'] = D['NgTextArea']['notes'].replace('automatic resize, ', '')
D['NgTextArea']['notes'] += '\n\n### Automatic height (0.47)\nAutoSize/autoSize defaults to false. When enabled, Rows/rows is the minimum visible line count and MaxRows/maxRows is the maximum (default 12). Both accept 1–30; the maximum must be at least the minimum in automatic mode. Fixed mode keeps Rows and ignores MaxRows for layout. The automatic field grows for newlines and wrapped text, shrinks on deletion/clear/external replacement and scrolls internally above the cap. It also adapts to width changes in read-only and disabled states. Sizing never changes the value or emits a value callback.\n\nBlazor uses a packaged JS module after interactive rendering; static SSR falls back to Rows. Automatic mode owns height and disables native manual resizing. Turning it off restores the previous inline height/overflow and normal fixed-mode behavior. Flutter uses native minLines/maxLines layout. The platforms retain their own font metrics and decorations, so equal row counts do not promise equal pixel heights. Avoid application CSS that overrides automatic height, line height or box sizing.\n'
D['NgTextArea']['blazor'] = '''<div class="ng-prompt-actions">
 <NgButton OnClick="()=>automatic=!automatic">Toggle automatic height</NgButton>
 <NgButton OnClick="LoadLong">Load long text</NgButton>
 <NgButton OnClick="()=>text="Short note"">Load short text</NgButton>
</div>
<NgCheckBox Label="Read only" @bind-Value="locked"/>
<NgTextArea Label="Delivery notes" @bind-Value="text" Rows="2" MaxRows="6" AutoSize="automatic"
 ReadOnly="locked" ShowClearButton="true" HelperText="Grows from 2 to 6 rows; longer notes scroll."/>
<p>Automatic height: @automatic · Length: @(text?.Length??0)</p>
@code {
 private bool automatic=true,locked; private string? text="Short note";
 private void LoadLong()=>text=string.Join("\\n",Enumerable.Range(1,14).Select(i=>$"Line {i}: a detailed delivery note."));
}
'''
D['NgTextArea']['blazor'] = D['NgTextArea']['blazor'].replace('OnClick="()=>text="Short note""', 'OnClick="LoadShort"').replace(' private void LoadLong()', ' private void LoadShort()=>text="Short note";\n private void LoadLong()')
D['NgTextArea']['dart'] = '''bool automatic = true, locked = false;
final editor = TextEditingController(text:'Short note');
@override void dispose(){editor.dispose();super.dispose();}
Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Wrap(spacing:8,runSpacing:8,children:[
  NgButton(onPressed:()=>setState(()=>automatic=!automatic),child:const Text('Toggle automatic height')),
  NgButton(onPressed:()=>setState(()=>editor.text=List.generate(14,(i)=>'Line ${i+1}: a detailed delivery note.').join('\\n')),child:const Text('Load long text')),
  NgButton(onPressed:()=>setState(()=>editor.text='Short note'),child:const Text('Load short text')),
 ]),
 NgCheckBox(label:'Read only',value:locked,onChanged:(v)=>setState(()=>locked=v)),
 NgTextArea(label:'Delivery notes',controller:editor,rows:2,maxRows:6,autoSize:automatic,
  readOnly:locked,showClearButton:true,helperText:'Grows from 2 to 6 rows; longer notes scroll.',onChanged:(_)=>setState((){})),
 Text('Automatic height: $automatic · Length: ${editor.text.length}'),
]);
'''

# Text appearance variants, 0.48.
for _editor in ('NgTextBox','NgTextArea'):
    D[_editor]['blazor'] = '<div class="ng-prompt-actions"><NgButton OnClick="CycleSize">Change size</NgButton><NgButton OnClick="CycleFill">Change fill</NgButton></div>\n<p>Size: @size · Fill: @fill</p>\n' + D[_editor]['blazor'].replace('<'+_editor+' ', '<'+_editor+' Size="@size" FillMode="@fill" ',1).replace('@code {', '@code {\n private string size="medium",fill="theme";\n private void CycleSize()=>size=size=="medium"?"large":size=="large"?"small":"medium";\n private void CycleFill()=>fill=fill=="theme"?"filled":fill=="filled"?"outline":"theme";')
    D[_editor]['dart'] = "String size='medium',fill='theme';\n" + D[_editor]['dart'].replace('children:[', "children:[\nWrap(spacing:8,children:[NgButton(onPressed:()=>setState(()=>size=size=='medium'?'large':size=='large'?'small':'medium'),child:const Text('Change size')),NgButton(onPressed:()=>setState(()=>fill=fill=='theme'?'filled':fill=='filled'?'outline':'theme'),child:const Text('Change fill'))]),\nText('Size: $size · Fill: $fill'),",1).replace(_editor+'(',_editor+"(size:size,fillMode:fill,",1)
    D[_editor]['notes'] += """

### Size and fill (0.48)
Size/size accepts small, medium (default), or large. FillMode/fillMode accepts theme (default), outline, or filled. Invalid values throw. Medium and theme inherit the existing application density/decoration. Small and large adjust text size and padding; they do not impose a fixed TextArea height. Outline removes background fill; filled uses a theme-aware surface. Borders, focus and validation indicators remain controlled by the platform/theme. Flutter custom themes should supply an outline border if that shape is required; fill selection does not replace theme borders.

Changing appearance preserves the value, selection and form state and emits no change callback. Automatic TextArea height recalculates with the new metrics. Read-only/disabled permissions and clear/password behavior remain unchanged. Flutter keeps native action hit targets; compact fields containing actions can therefore remain taller than fields without actions. Prefix/suffix templates keep their own sizing. The two platforms do not promise equal pixel heights. Debounced notifications and further radius/border customization remain open.
"""
