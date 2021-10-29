
{{ $short := (shortname .Type.Name "err" "sqlstr" "db" "q" "res" .Fields) }}
{{ $table := (schema .Schema .Type.Table.TableName) }}

// {{ .FuncName }} retrieves a row from '{{ $table }}' as a {{ .Type.Name }}.
//
// Generated from index '{{ .Index.IndexName }}'.
func {{ .FuncName }}(ctx context.Context, db DbConn{{ goparamlist .Fields true true }}) ({{ if not .Index.IsUnique }}[]{{ end }}*{{ .Type.Name }}, error) {
var err error

// sql query
const sqlstr = `SELECT ` +
`{{ colnames .Type.Fields }} ` +
`FROM {{ $table }} ` +
`WHERE {{ colnamesquery .Fields " AND " }}`

// run query
{{- if .Index.IsUnique }}
	{{ $short }} := {{ .Type.Name }}{}

	err = db.QueryRowContext(ctx, sqlstr{{ goparamlist .Fields true false }}).Scan({{ fieldnames .Type.Fields (print "&" $short) }})
	if err != nil {
	return nil, err
	}

	return &{{ $short }}, nil
{{- else }}
	q, err := db.QueryContext(ctx, sqlstr{{ goparamlist .Fields true false }})
	if err != nil {
	return nil, err
	}
	defer q.Close()

	// load results
	res := []*{{ .Type.Name }}{}
	for q.Next() {
	{{ $short }} := {{ .Type.Name }}{}

	// scan
	err = q.Scan({{ fieldnames .Type.Fields (print "&" $short) }})
	if err != nil {
	return nil, err
	}

	res = append(res, &{{ $short }})
	}

	return res, nil
{{- end }}
}

{{- if and .Index.IsUnique (not .Index.IsPrimary) }}
{{ if ne (fieldnamesmulti .Type.Fields $short .Type.PrimaryKeyFields) "" }}
// {{ .UpdateFuncName }} updates the {{ .Type.Name }} in the database.
func({{ $short }} *{{ .Type.Name }}) {{ .UpdateFuncName }}(ctx context.Context, db DbConn) (err error) {
	const sqlstr = `UPDATE {{ $table }} SET ` +
	`{{ colnamesupdatequery .Type.Fields ", " .Type.PrimaryKey.Name .FieldNamesArray }}` +
	` WHERE {{ .Index.IndexName }} = ?`

	_, err = db.ExecContext(ctx, sqlstr, {{ updatefieldnames .Type.Fields $short .Type.PrimaryKey.Name .FieldNamesArray }}, {{ $short }}.{{ .ParamNames }})
	return err
}
{{ else }}
// Update statements omitted due to lack of fields other than primary key
{{ end }}
{{- end }}
