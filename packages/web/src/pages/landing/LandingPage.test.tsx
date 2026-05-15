import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import type { ReactElement } from 'react'
import LandingPage from './LandingPage'
import '../../test/setup-landing'

// 测试辅助函数
const renderWithRouter = (component: ReactElement) => {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('LandingPage', () => {
  it('renders the main heading KidMemory', () => {
    renderWithRouter(<LandingPage />)

    const heading = screen.getByRole('heading', { name: /kidmemory/i, level: 1 })
    expect(heading).toBeInTheDocument()
  })

  it('displays the Chinese slogan by default', () => {
    renderWithRouter(<LandingPage />)

    const slogan = screen.getByText(/把孩子的照片、画作与成长瞬间/i)
    expect(slogan).toBeInTheDocument()
  })

  it('shows navigation with GitHub link', () => {
    renderWithRouter(<LandingPage />)

    const githubLink = screen.getByRole('link', { name: /github repository/i })
    expect(githubLink).toBeInTheDocument()
    expect(githubLink).toHaveAttribute('href', 'https://github.com/xingbofeng/kidmemory')
  })

  it('displays CTA buttons for vision and quick start', () => {
    renderWithRouter(<LandingPage />)

    const visionButton = screen.getByRole('link', { name: /阅读产品愿景/i })
    const quickStartButtons = screen.getAllByRole('link', { name: /快速开始/i })

    expect(visionButton).toBeInTheDocument()
    expect(quickStartButtons).toHaveLength(2)
    // 验证两个快速开始按钮都指向 /app
    quickStartButtons.forEach(button => {
      expect(button).toHaveAttribute('href', '/app')
    })
  })

  it('shows product tags', () => {
    renderWithRouter(<LandingPage />)

    // 查找所有包含这些文本的元素，然后验证标签区域
    const localFirstTags = screen.getAllByText(/本地优先/i)
    const agentDrivenTags = screen.getAllByText(/agent 驱动/i)
    const publishGradeTags = screen.getAllByText(/出版级输出/i)

    // 验证至少存在这些标签
    expect(localFirstTags.length).toBeGreaterThan(0)
    expect(agentDrivenTags.length).toBeGreaterThan(0)
    expect(publishGradeTags.length).toBeGreaterThan(0)
  })
})