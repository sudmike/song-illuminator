package api

import (
	"encoding/json"
	"net/http"

	"github.com/graphql-go/graphql"
)

type GraphQL struct {
	schema graphql.Schema
}

func NewGraphQL(environment string, firestoreEnabled bool) (*GraphQL, error) {
	serviceType := graphql.NewObject(graphql.ObjectConfig{
		Name: "ServiceInfo",
		Fields: graphql.Fields{
			"name":             &graphql.Field{Type: graphql.NewNonNull(graphql.String)},
			"environment":      &graphql.Field{Type: graphql.NewNonNull(graphql.String)},
			"firestoreEnabled": &graphql.Field{Type: graphql.NewNonNull(graphql.Boolean)},
		},
	})
	query := graphql.NewObject(graphql.ObjectConfig{
		Name: "Query",
		Fields: graphql.Fields{
			"serviceInfo": &graphql.Field{
				Type: graphql.NewNonNull(serviceType),
				Resolve: func(graphql.ResolveParams) (interface{}, error) {
					return map[string]interface{}{
						"name": "Song Illuminator", "environment": environment,
						"firestoreEnabled": firestoreEnabled,
					}, nil
				},
			},
		},
	})
	schema, err := graphql.NewSchema(graphql.SchemaConfig{Query: query})
	if err != nil {
		return nil, err
	}
	return &GraphQL{schema: schema}, nil
}

func (g *GraphQL) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var request struct {
		Query         string                 `json:"query"`
		Variables     map[string]interface{} `json:"variables"`
		OperationName string                 `json:"operationName"`
	}
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, "invalid GraphQL request", http.StatusBadRequest)
		return
	}
	result := graphql.Do(graphql.Params{
		Schema: g.schema, RequestString: request.Query,
		VariableValues: request.Variables, OperationName: request.OperationName,
		Context: r.Context(),
	})
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(result)
}
