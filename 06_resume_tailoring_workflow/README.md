# Resume tailoring workflow

## About this project

During a high volume job search I was rewriting my resume for every posting by hand. I built a workflow to make that faster while keeping a person in charge of the final document.

## The workflow

1. **Read the posting.** Pull out the skills, tools and phrases the employer uses most.
2. **Check coverage.** Compare those terms with the resume and list what is missing. The script in this folder does this step.
3. **Tailor.** A Claude skill I set up picks the closest version of my resume, rewrites bullet points to use the posting's own wording where it is true of my experience, and produces a Word document.
4. **Review.** I read every line before it goes out. Nothing is added that I did not do.
5. **Submit by hand.** Applications are never submitted automatically.

I have also designed an extension in n8n that would watch job boards each day, filter postings by my criteria, and send me a digest to approve before step 3 runs. That part is a design and is not built yet.

## What is in this folder

`code/keyword_check.py` is a small Python script with no outside libraries. It reads a job posting and a resume as plain text, finds the 25 words and two word phrases the posting uses most, and reports which ones the resume is missing.

The files in `sample` are made up examples, not a real posting or a real resume. The output for them is saved in `output/sample_output.txt`:

```
Key terms in the posting: 25
Found in the resume:      4 (16%)
```

## Why the human steps stay

* Automated matching can suggest wording that overstates experience. Only the applicant knows what is true.
* Many application sites do not allow automated submissions.
* A keyword match shows overlap in wording. It does not show whether someone is a good fit for the role.

## How to run

```
python3 code/keyword_check.py sample/sample_posting.txt sample/sample_resume.txt
```
