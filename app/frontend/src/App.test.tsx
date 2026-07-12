import '@testing-library/jest-dom/vitest'
import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { App } from './App'

describe('App', () => {
  it('renders the application shell', () => {
    render(<App />)
    expect(
      screen.getByRole('heading', { name: /bring the color of music/i }),
    ).toBeInTheDocument()
  })
})
