import React from 'react';

const ExperienceSection: React.FC = () => {
  return (
    <section id="experience">
      <div className="head">
        <h2 data-i18n="experienceTitle">从素材到作品，是一条出版管线。</h2>
        <p data-i18n="experienceDesc">KidMemory 的体验不是"上传后生成一下"，而是从采集、整理、搜索、候选、生成、预览、导出到归档的连续工作流。</p>
      </div>
      <div className="flow">
        <article className="step">
          <small>01</small>
          <h3 data-i18n="f1Title">Capture</h3>
          <p data-i18n="f1Desc">手机扫码上传、相册选择、桌面拖拽，让纸面作品和生活瞬间进入素材库。</p>
        </article>
        <article className="step">
          <small>02</small>
          <h3 data-i18n="f2Title">Curate</h3>
          <p data-i18n="f2Desc">为素材补充标题、标签、描述、时间、来源和孩子档案上下文。</p>
        </article>
        <article className="step">
          <small>03</small>
          <h3 data-i18n="f3Title">Search</h3>
          <p data-i18n="f3Desc">用自然语言寻找素材，例如"找画了太阳的作品"或"找适合做封面的图"。</p>
        </article>
        <article className="step">
          <small>04</small>
          <h3 data-i18n="f4Title">Publish</h3>
          <p data-i18n="f4Desc">Agent 生成结构化书稿，系统校验并导出 PDF、长图与未来更多作品形态。</p>
        </article>
      </div>
    </section>
  );
};

export default ExperienceSection;