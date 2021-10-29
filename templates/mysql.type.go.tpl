{{- $short := (shortname .Name "err" "res" "sqlstr" "db") -}}
{{- $table := (schema .Schema .Table.TableName) -}}

const TblName_{{ .Schema }}{{ .Table.TableName }} = "{{ $table }}"


{{- if .Comment -}}
	// {{ .Comment }}
{{ else }}
	// {{ .Name }} represents a row from '{{ $table }}'.
{{- end }}
type {{ .Name }} struct {
{{- range .Fields }}
	{{ .Name }} {{ retype .Type }} `json:"{{ .Col.ColumnName }}"` // {{ .Col.ColumnName }}
{{- end }}
}

// {{ .Name }}ColsAll is an array of all "{{ .Name }}" fields
var {{ .Name }}ColsAll = []string{ {{ colnamessliceall .Fields }} }

// {{ .Name }}ColsForUpdate is an array of "{{ .Name }}" fields without primaryKey field.
var {{ .Name }}ColsForUpdate = []string{ {{ colnamessliceforupdate .Fields .PrimaryKey.Name }} }

// {{ .Name }}ColsForUpdate is an array of "{{ .Name }}" fields without primaryKey field.
var {{ .Name }}ColsForInsert = []string{ {{ colnamessliceforinsert .Fields .PrimaryKey.Name }} }

// AllValues returns all the fields values to be used
// for SQL inserts. Pass as "item.InsertValues()..." with three dots
func ({{ $short }} *{{ .Name }}) InsertValues() []interface{} {
	return []interface{}{ {{ fieldnames .Fields $short }} }
}

// UpdateValues returns all the fields values to be used
// for SQL inserts. Pass as "item.UpdateValues()..." with three dots
func ({{ $short }} *{{ .Name }}) UpdateValues() []interface{} {
	return []interface{{"{}"}}{{"{"}} {{ updatefieldnames .Fields $short .PrimaryKey.Name }} {{"}"}}
}

// InsertValues returns all the fields values to be used
// for SQL inserts. Pass as "item.InsertValues()..." with three dots
func ({{ $short }} *{{ .Name }}) InsertValues() []interface{} {
	return []interface{{"{}"}}{{"{"}} {{ fieldnames .Fields $short .PrimaryKey.Name }} {{"}"}}
}

{{ if .PrimaryKey }}

	// Insert inserts the {{ .Name }} to the database.
	func ({{ $short }} *{{ .Name }}) Insert(ctx context.Context, db DbConn) error {
	var err error

	{{ if .Table.ManualPk  }}
		// sql insert query, primary key must be PROVIDED {{ .Table.ManualPk  }}
		const sqlstr = `INSERT INTO {{ $table }} (` +
		`{{ colnames .Fields }}` +
		`) VALUES (` +
		`{{ colvals .Fields }}` +
		`)`

		// run query
		_, err = db.ExecContext(ctx, sqlstr, {{ fieldnames .Fields $short }})
		if err != nil {
		return err
		}

	{{ else }}
		// sql insert query, primary key provided by autoincrement
		const sqlstr = `INSERT INTO {{ $table }} (` +
		`{{ colnames .Fields .PrimaryKey.Name }}` +
		`) VALUES (` +
		`{{ colvals .Fields .PrimaryKey.Name }}` +
		`)`

		// run query
		res, err := db.ExecContext(ctx, sqlstr, {{ fieldnames .Fields $short .PrimaryKey.Name }})
		if err != nil {
		return err
		}

		// retrieve id
		id, err := res.LastInsertId()
		if err != nil {
		return err
		}

		// set primary key and existence
		{{ $short }}.{{ .PrimaryKey.Name }} = {{ .PrimaryKey.Type }}(id)
	{{ end }}

	return nil
	}

	{{ if ne (fieldnamesmulti .Fields $short .PrimaryKeyFields) "" }}
		// Update updates the {{ .Name }} in the database.
		func ({{ $short }} *{{ .Name }}) Update(ctx context.Context, db DbConn) error {
		var err error

		{{ if gt ( len .PrimaryKeyFields ) 1 }}
			// sql query with composite primary key
			const sqlstr = `UPDATE {{ $table }} SET ` +
			`{{ colnamesquerymulti .Fields ", " 0 .PrimaryKeyFields true }}` +
			` WHERE {{ colnamesquery .PrimaryKeyFields " AND " }}`

			// run query
			_, err = db.ExecContext(ctx, sqlstr, {{ fieldnamesmulti .Fields $short .PrimaryKeyFields }}, {{ fieldnames .PrimaryKeyFields $short}})
			return err
		{{- else }}
			// sql query
			const sqlstr = `UPDATE {{ $table }} SET ` +
			`{{ colnamesupdatequery .Fields ", " .PrimaryKey.Name }}` +
			` WHERE {{ colname .PrimaryKey.Col }} = ?`

			// run query
			_, err = db.ExecContext(ctx, sqlstr, {{ updatefieldnames .Fields $short .PrimaryKey.Name }}, {{ $short }}.{{ .PrimaryKey.Name }})
			return err
		{{- end }}
		}
	{{ else }}
		// Update statements omitted due to lack of fields other than primary key
	{{ end }}

	// Delete deletes the {{ .Name }} from the database.
	func ({{ $short }} *{{ .Name }}) Delete(ctx context.Context, db DbConn) error {
	var err error

	{{ if gt ( len .PrimaryKeyFields ) 1 }}
		// sql query with composite primary key
		const sqlstr = `DELETE FROM {{ $table }} WHERE {{ colnamesquery .PrimaryKeyFields " AND " }}`

		// run query
		_, err = db.ExecContext(ctx, sqlstr, {{ fieldnames .PrimaryKeyFields $short }})
		if err != nil {
		return err
		}
	{{- else }}
		// sql query
		const sqlstr = `DELETE FROM {{ $table }} WHERE {{ colname .PrimaryKey.Col }} = ?`

		// run query
		_, err = db.ExecContext(ctx, sqlstr, {{ $short }}.{{ .PrimaryKey.Name }})
		if err != nil {
		return err
		}
	{{- end }}

	return nil
	}
{{- end }}