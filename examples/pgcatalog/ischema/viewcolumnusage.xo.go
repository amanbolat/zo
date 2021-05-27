// Package ischema contains the types for schema 'information_schema'.
package ischema

import "github.com/amanbolat/zo/examples/pgcatalog/pgtypes"

// Code generated by xo. DO NOT EDIT.

// ViewColumnUsage represents a row from 'information_schema.view_column_usage'.
type ViewColumnUsage struct {
	ViewCatalog  pgtypes.SQLIdentifier `json:"view_catalog"`  // view_catalog
	ViewSchema   pgtypes.SQLIdentifier `json:"view_schema"`   // view_schema
	ViewName     pgtypes.SQLIdentifier `json:"view_name"`     // view_name
	TableCatalog pgtypes.SQLIdentifier `json:"table_catalog"` // table_catalog
	TableSchema  pgtypes.SQLIdentifier `json:"table_schema"`  // table_schema
	TableName    pgtypes.SQLIdentifier `json:"table_name"`    // table_name
	ColumnName   pgtypes.SQLIdentifier `json:"column_name"`   // column_name
}