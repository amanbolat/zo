// Package ischema contains the types for schema 'information_schema'.
package ischema

import "github.com/amanbolat/zo/examples/pgcatalog/pgtypes"

// Code generated by xo. DO NOT EDIT.

// EnabledRole represents a row from 'information_schema.enabled_roles'.
type EnabledRole struct {
	RoleName pgtypes.SQLIdentifier `json:"role_name"` // role_name
}