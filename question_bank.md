# Introduction to Infectious Disease Modelling — Question Bank

40 multiple-choice questions spanning infectious disease modelling fundamentals, from basic to intermediate.
Each question is tagged with its **type**:

- **[Single]** — exactly one correct answer.
- **[Multi]** — one or more correct answers (select all that apply).
- **[T/F]** — true/false (read carefully — none are meant to be obvious).

The correct answer and a brief explanation are shown immediately after each question.

---

## Section 1 — Infectious diseases & control measures

**Q1. [Single]** Diseases can be classified by cause, duration, mode of transmission, and impact on the host. Which statement about these classifications is correct?

- A) A disease can only ever belong to one of these categories at a time.
- B) The categories are mutually exclusive.
- **C) The categories are *not* mutually exclusive, so a disease can fall under several at once.**
- D) Mode of transmission is the only classification that matters for modelling.

**Answer:** C — Classifications are *not* mutually exclusive.

---

**Q2. [Multi]** Which of the following are examples of **pharmaceutical interventions (PIs)**?

- **A) Vaccines**
- B) Quarantine
- **C) Antiviral drugs**
- **D) Antibiotics**
- E) Physical/social distancing

**Answer:** A, C, D — Quarantine and distancing are NPIs, not PIs.

---

**Q3. [Multi]** Which of the following are genuine **challenges with vaccination**?

- **A) Vaccines take time to develop for new pathogens.**
- **B) Vaccines are never 100% effective and offer limited duration of protection.**
- **C) Some pathogens mutate rapidly.**
- D) Vaccines always require the pathogen to be eradicated first.
- **E) Logistical challenges such as cold-chain requirements.**

**Answer:** A, B, C, E — D is invented; eradication is not a prerequisite.

---

**Q4. [Single]** Quarantine involves isolating individuals who *may* have been exposed to a contagious disease. What is a key advantage of quarantine as a control measure?

- A) It is cheap in all circumstances.
- **B) It is simple, and its effectiveness does **not** depend on the disease.**
- C) It never infringes on individual rights.
- D) It is always easy to enforce.

**Answer:** B — Its effectiveness does not depend on the disease.

---

**Q5. [T/F]** Contact tracing is purely a treatment method and plays no role in disease surveillance.

- A) True
- **B) False**

**Answer:** False — Contact tracing is a *critical component of surveillance*, not just treatment.

---

## Section 2 — What are infectious disease models?

**Q6. [Single]** The famous aphorism "all models are wrong, but some are useful" is attributed to:

- A) Kermack and McKendrick
- **B) George Box**
- C) Diekmann
- D) Heesterbeek

**Answer:** B — George Box (Box, 1979).

---

**Q7. [Multi]** In what sense are all models "wrong" by definition? (Select all that apply.)

- **A) They simplify reality.**
- **B) They cannot fully capture all the complexities of the system being studied.**
- C) They are always programmed with bugs.
- D) They deliberately ignore the biology of the pathogen in every case.

**Answer:** A, B — Models are "wrong" because they simplify reality and can't capture all complexity.

---

**Q8. [Multi]** Which factors influence the formulation or choice of a model?

- **A) Accuracy**
- **B) Transparency**
- **C) Flexibility**
- D) The modeller's nationality

**Answer:** A, B, C — Accuracy, transparency, flexibility.

---

**Q9. [Single]** For a model whose primary purpose is **predicting the future course** of an epidemic, which property is most essential?

- A) Transparency
- B) Flexibility
- **C) Accuracy**
- D) Simplicity

**Answer:** C — Prediction must be accurate.

---

**Q10. [T/F]** The 2014 CDC Ebola forecast is a classic example of a highly accurate epidemic prediction.

- A) True
- **B) False**

**Answer:** False — It was an estimate that was way off (~65× worse than reality).

---

**Q11. [Multi]** Which of the following are genuine **limitations of infectious disease models**?

- **A) Host behaviour is often difficult to predict.**
- **B) The pathogen may have known/unknown characteristics that are hard to capture.**
- **C) Data is often unavailable or of poor quality.**
- D) Models can never be run on a computer.

**Answer:** A, B, C — D is false.

---

## Section 3 — Types of models

**Q12. [Multi]** Infectious disease models can be classified along several axes. Which of the following are valid classification axes?

- **A) Mechanistic vs. phenomenological (mathematical approach)**
- **B) Deterministic vs. stochastic (randomness)**
- **C) Discrete vs. continuous (time)**
- **D) Spatial vs. non-spatial (space)**
- **E) Homogeneous vs. heterogeneous (population structure)**

**Answer:** A, B, C, D, E — All five axes are valid.

---

**Q13. [Single]** Which description best matches a **mechanistic** model?

- A) It focuses on describing patterns in data without modelling biological mechanisms.
- **B) It explicitly models underlying biological processes such as host–pathogen interactions and disease natural history.**
- C) It is always a simple regression fit to case counts.
- D) It cannot be used to test intervention scenarios.

**Answer:** B — Mechanistic = models underlying biological processes.

---

**Q14. [Multi]** Which of the following are examples of **phenomenological** models?

- **A) Curve fitting**
- **B) Time series models**
- C) SEIR models
- **D) Regression models**
- E) Agent-based models

**Answer:** A, B, D — SEIR and agent-based are mechanistic.

---

**Q15. [T/F]** A key advantage of phenomenological models over mechanistic models is that they extrapolate beyond observed data more reliably.

- A) True
- **B) False**

**Answer:** False — Phenomenological models extrapolate *poorly*; good extrapolation is a mechanistic advantage.

---

**Q16. [Single]** For which situation are **deterministic** models best suited?

- A) Small populations (< 1,000) in the early epidemic phase.
- B) Capturing extinction/fade-out events.
- **C) Large populations (> 10,000), general trends, and when computational efficiency matters.**
- D) Quantifying uncertainty through many random runs.

**Answer:** C — Large populations, general trends, efficiency.

---

**Q17. [Multi]** For which situations are **stochastic** models the better choice?

- **A) Small populations (< 1,000)**
- **B) Early epidemic phases**
- **C) Uncertainty quantification**
- **D) Extinction events**
- E) When you specifically want the same output for the same input every time

**Answer:** A, B, C, D — E describes deterministic models, not stochastic.

---

**Q18. [T/F]** A limitation of deterministic models is that they cannot capture fade-out (extinction) in small populations.

- **A) True**
- B) False

**Answer:** True — A genuine deterministic limitation.

---

**Q19. [Single]** Which equation form is characteristic of a **discrete-time** model?

- A) $\frac{dS}{dt} = -\beta S I$
- **B) $S_{t+1} = S_t - \beta S_t I_t$**
- C) $R_0 = \beta / \gamma$
- D) $\lambda = \beta I / N$

**Answer:** B — Difference equation $S_{t+1}=S_t-\beta S_t I_t$.

---

**Q20. [Multi]** Which of the following time-scale pairings are appropriate?

- **A) Acute diseases (days) → discrete time often sufficient**
- **B) Chronic diseases (years) → continuous time may be better**
- **C) Daily surveillance data → discrete time natural**
- D) Policy timing → continuous time only

**Answer:** A, B, C — D is wrong; for policy timing, discrete time is practical (not "continuous only").

---

**Q21. [Single]** In a **metapopulation** model, the population is represented as:

- A) Individuals as nodes and contacts as edges.
- **B) Discrete patches connected by migration.**
- C) A single well-mixed compartment.
- D) Individuals distributed in continuous space with transmission kernels.

**Answer:** B — Metapopulation = discrete patches connected by migration.

---

**Q22. [Single]** In a **network** model, individuals and their relationships are represented as:

- A) Patches and migration routes.
- **B) Nodes and edges.**
- C) Compartments and transition rates only.
- D) Continuous space and kernels.

**Answer:** B — Nodes and edges.

---

**Q23. [Multi]** Which of the following are common types of **heterogeneity** that can be incorporated into a model?

- **A) Age structure**
- **B) Risk groups**
- **C) Immunity status**
- **D) Geographic differences**
- E) The programming language used

**Answer:** A, B, C, D — E is invented.

---

**Q24. [Multi]** Which of the following are advantages of **network models**?

- **A) Capture realistic contact patterns**
- **B) Can model targeted interventions such as contact tracing**
- **C) Account for superspreading events**
- D) Require no contact data at all

**Answer:** A, B, C — D contradicts the fact that networks *require* detailed contact data.

---

**Q25. [Single]** When building a model, which overall strategy is generally recommended?

- A) Start with the most complex individual-based model, then simplify.
- **B) Start simple and add complexity gradually only when justified.**
- C) Always use a stochastic spatial network model from the outset.
- D) Avoid compartmental models entirely.

**Answer:** B — Start simple; add complexity gradually.

---

## Section 4 — Compartmental models

**Q26. [Multi]** Within a single compartment of a compartmental model, individuals are assumed to:

- **A) Share the same features (disease state, age, location, etc.).**
- **B) Be in only one compartment at a time.**
- **C) Move between compartments based on defined transition rates.**
- D) Be able to occupy several compartments simultaneously.

**Answer:** A, B, C — D contradicts "one compartment at a time."

---

**Q27. [Single]** This introductory course focuses on which specific class of compartmental model?

- A) Stochastic, discrete-time models
- **B) Deterministic compartmental models with continuous time scales**
- C) Phenomenological regression models
- D) Agent-based models

**Answer:** B — Deterministic, continuous-time compartmental models.

---

**Q28. [T/F]** Compartmental models are essentially the same as statistical models, since both describe relationships between variables.

- A) True
- **B) False**

**Answer:** False — Compartmental models are *different from* statistical models.

---

## Section 5 — The SIR model & force of infection

**Q29. [Multi]** In the SIR model, which of the following correctly describe the compartments?

- **A) Susceptible (S): not infected but can be infected.**
- **B) Infected (I): infected and infectious.**
- **C) Recovered/Removed (R): no longer infected and cannot be re-infected.**
- D) Susceptible (S): infected but not yet infectious.

**Answer:** A, B, C — D describes the Exposed compartment, not Susceptible.

---

**Q30. [Multi]** The force of infection (FOI), $\lambda$, is composed of the probabilities/rates that:

- **A) Contacts happen.**
- **B) A given contact is with an infected individual.**
- **C) A contact results in successful transmission.**
- D) An individual is born into the susceptible compartment.

**Answer:** A, B, C — D (births) is not part of the FOI.

---

**Q31. [Single]** The force of infection, $\lambda$, is best defined as:

- A) The total number of infected individuals in the population.
- **B) The per-capita rate at which susceptible individuals become infected.**
- C) The rate at which infected individuals recover.
- D) The average number of secondary infections from one case.

**Answer:** B — Per-capita rate of infection of susceptibles.

---

**Q32. [Single]** Which transmission formulation is used in this course, and for which type of disease is it appropriate?

- A) Frequency-dependent; sexually transmitted diseases.
- **B) Density-dependent; airborne/directly transmitted diseases such as measles.**
- C) Frequency-dependent; airborne diseases.
- D) Density-dependent; sexually transmitted diseases.

**Answer:** B — Density-dependent; suits measles/airborne diseases.

---

**Q33. [T/F]** In the SIR model, if the average duration of infection is $1/\gamma$, then the recovery rate is $\gamma$.

- **A) True**
- B) False

**Answer:** True — Duration $1/\gamma$ ⇒ rate $\gamma$.

---

**Q34. [Multi]** Which of the following are **assumptions** of the basic SIR model?

- **A) The population is closed (no births, deaths, or migration).**
- **B) Mixing is homogeneous (individuals mix randomly).**
- **C) Individuals acquire lifelong immunity after recovery.**
- D) Transition rates change continuously over time.
- **E) Individuals are infectious immediately after infection.**

**Answer:** A, B, C, E — D is false; transition rates are constant over time.

---

**Q35. [Single]** For the SIR model, the basic reproduction number $R_0$ is given by:

- A) $\gamma / \beta$
- **B) $\beta / \gamma$**
- C) $\beta \sigma / [(\gamma+\mu)(\sigma+\mu)]$
- D) $\beta S I - \gamma I$

**Answer:** B — $R_0 = \beta/\gamma$ (note $\gamma/\beta$ is the *relative removal rate*).

---

**Q36. [T/F]** The basic reproduction number $R_0$ has units of "infections per day."

- A) True
- **B) False**

**Answer:** False — $R_0$ is unitless and dimensionless.

---

**Q37. [Single]** Which statement correctly describes the threshold interpretation of $R_0$?

- A) If $R_0 > 1$ the epidemic declines; if $R_0 < 1$ it grows.
- **B) If $R_0 > 1$ the epidemic grows; if $R_0 < 1$ it declines.**
- C) $R_0$ has no relationship to whether an epidemic grows.
- D) An epidemic always grows regardless of $R_0$.

**Answer:** B — $R_0>1$ grows, $R_0<1$ declines.

---

## Section 6 — SEIR model & interventions

**Q38. [Single]** What does the **exposed (E)** compartment in the SEIR model represent?

- A) Individuals who are infected *and* infectious.
- **B) Individuals who are infected but **not yet infectious** (latent period).**
- C) Individuals who are fully recovered and immune.
- D) Individuals who have been vaccinated.

**Answer:** B — Infected but not yet infectious (latent period).

---

**Q39. [Single]** For complex models such as the SEIR model, which approach is used to derive $R_0$?

- A) Simple threshold analysis, exactly as for the SIR model.
- **B) The next-generation matrix approach.**
- C) Curve fitting to case data.
- D) It is impossible to derive $R_0$ for the SEIR model.

**Answer:** B — Next-generation matrix approach.

---

**Q40. [Multi]** Which of the following statements about modelling interventions are correct?

- **A) Vaccination conceptually works by reducing the number of susceptibles, $S$.**
- **B) NPIs such as social distancing act by reducing the transmission rate, $\beta$.**
- **C) Isolation can be modelled by moving infected individuals into a separate compartment ($Q$) where they no longer transmit.**
- D) In an age-structured SIR model with $n$ age groups, the model has exactly 3 compartments regardless of $n$.

**Answer:** A, B, C — D is false; the age-structured model has $3n$ compartments.

---

---

## Notes for instructors

- **Tricky / distractor-heavy items:** Q5, Q10, Q15, Q20, Q28, Q35, Q36 rely on common misconceptions (e.g., $\gamma/\beta$ vs. $\beta/\gamma$; $R_0$ being dimensionless; phenomenological vs. mechanistic extrapolation).
- **Multi-select items** (Q2, Q3, Q7, Q8, Q11, Q12, Q14, Q17, Q20, Q23, Q24, Q26, Q29, Q30, Q34, Q40) each contain at least one plausible-but-wrong distractor to discourage "select-all" guessing.
- **True/False items** (Q5, Q10, Q15, Q18, Q28, Q33, Q36) are deliberately framed against intuition or as reversed statements rather than as obvious facts.
