import React, { useEffect } from 'react';
import LandingHeader from './LandingHeader';
import HeroSection from './HeroSection';
import VisionSection from './VisionSection';
import ExperienceSection from './ExperienceSection';
import ScreensSection from './ScreensSection';
import ArchitectureSection from './ArchitectureSection';
import RoadmapSection from './RoadmapSection';
import FinalSection from './FinalSection';
import LandingFooter from './LandingFooter';

const LandingPage: React.FC = () => {
  useEffect(() => {
    // 添加 reveal 动画效果
    const revealTargets = [
      ".hero > div:first-child",
      ".desktop",
      ".phone",
      ".note-card",
      "section .head",
      ".card",
      ".step",
      ".show-main",
      ".show-side article",
      ".agent-map",
      ".mini",
      ".phase",
      ".final"
    ];

    const nodes = document.querySelectorAll(revealTargets.join(","));
    nodes.forEach((node, index) => {
      node.classList.add("reveal");
      (node as HTMLElement).style.setProperty("--delay", `${Math.min(index % 8, 7) * 70}ms`);
    });

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("in-view");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.16, rootMargin: "0px 0px -8% 0px" });

    nodes.forEach((node) => observer.observe(node));

    // 清理函数
    return () => {
      observer.disconnect();
    };
  }, []);

  return (
    <div className="landing-page">
      <LandingHeader />
      <main id="top" className="page">
        <HeroSection />
        <VisionSection />
        <ExperienceSection />
        <ScreensSection />
        <ArchitectureSection />
        <RoadmapSection />
        <FinalSection />
      </main>
      <LandingFooter />
    </div>
  );
};

export default LandingPage;