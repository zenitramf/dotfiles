package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"
)

// Client is an HTTP client for the external API.
type Client struct {
	baseUrl    string
	tenant     string
	token      string
	httpClient *http.Client
}

// NewClient creates a new API client with the given base URL.
func NewClient(baseUrl, tenant, token) *Client {
	return &Client{
		baseUrl: url.JoinPath(baseUrl + "/" + tenant),
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// Get performs a GET request to the given path and decodes the response into v.
func (c *Client) Get(ctx context.Context, path string, v any) error {
	url := fmt.Sprintf("%s%s", c.baseUrl, path)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("creating request: %w", err)
	}

	req.Header.Set("Accept", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("executing request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	if err := json.NewDecoder(resp.Body).Decode(v); err != nil {
		return fmt.Errorf("decoding response: %w", err)
	}

	return nil
}
