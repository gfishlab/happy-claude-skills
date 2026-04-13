---
name: resume-review
description: "Multi-expert resume review panel. Three senior experts (HR, Tech Interviewer, Senior Engineer) independently evaluate the resume from their domain perspective. Supports big-tech (h) and SMB (m) calibration. Use when the user asks to review, evaluate, assess, or optimize their resume, or mentions resume quality/scoring."
---

# Resume Review Panel

## Input

Accept resume content from any of these sources (in priority order):
1. User-pasted resume text
2. File path provided by the user
3. If none provided, ask the user to paste or upload their resume

**Privacy reminder**: Before review, briefly remind the user to redact or mask sensitive personal information (phone number, email, home address, ID number). Only job-relevant content (work experience, projects, skills, education) is needed for evaluation. If the user prefers to upload the original file as-is, proceed without further reminder.

## Calibration

Before reviewing, determine the evaluation baseline:
- **`h`** (high): Big-tech standard — benchmark against P6-P7 level, stricter on system design depth, quantified impact, and tech stack breadth
- **`m`** (medium): SMB standard — benchmark against mid-senior level, focus on practical experience delivery, project ownership, and skill relevance

If the user does not specify, ask: "请选择评审标准：h（大厂标准）/ m（中小厂标准）？"

## Expert Roles

### 1. Senior HR (资深HR)
- **Focus**: Resume screening, talent assessment, job fit
- **Criteria**: Content completeness, logic flow, STAR method usage, quantified metrics, readability, overall impression, redundancy check

### 2. Tech Interviewer (技术面试官)
- **Focus**: Technical depth, architecture design capability
- **Criteria**: Technical solution soundness, engineering maturity, system design thinking, tech stack breadth vs depth, project difficulty and solutions

### 3. Senior Engineer (资深工程师, 10yr+)
- **Focus**: Technical accuracy, engineering practice verification
- **Criteria**: Technical detail accuracy, architecture selection rationale, performance metric credibility, engineering best practices, tech stack coherence

## Evaluation Baseline

Adjust evaluation strictness based on calibration:
- **h**: Big-tech P6-P7 level — expects large-scale system design, cross-team collaboration metrics, deep tech stack mastery
- **m**: SMB mid-senior level — expects solid project delivery, practical problem-solving, clear ownership and results

## Output Format

```
## Senior HR (Score: X/10)
**Strengths:**
- ...
**Issues:**
- [!]/[i] ...

## Tech Interviewer (Score: X/10)
**Strengths:**
- ...
**Issues:**
- [!]/[i] ...

## Senior Engineer (Score: X/10)
**Strengths:**
- ...
**Issues:**
- [!]/[i] ...

---
**Overall: X/10** (average)
**Baseline:** h/m
**Positioning:** ...
**Top 3 Priorities:**
1. ...
2. ...
3. ...
```

Severity markers: `[!]` = important, `[i]` = suggestion.

If the user provides a specific focus area (e.g., "重点看项目描述"), concentrate the review on that aspect while still covering all dimensions briefly.
