# Al-Noor Academy website

A single-page website for Al-Noor Academy (online Quran & Islamic Studies).
Everything is in `index.html`. No build step is needed: open it in a browser,
or upload it to any static host (Netlify, GitHub Pages, Vercel, cPanel…).

## Sections
Hero · About · Courses (filterable) · One-on-One & Group classes with fees ·
How it works · Enrolment form · FAQ · Inquiry/contact form · Footer ·
floating WhatsApp button.

## Editing content
At the bottom of `index.html`, in the `<script>` block under **SETTINGS**:

- `COURSES`: add, remove or edit courses. Cards, the enrolment dropdown and the
  footer list update automatically.
- `PLANS`: monthly fees and features for One-on-One and Group classes.
- `CONTACT_EMAIL`: where form messages go.

Also search-and-replace the placeholder phone `+1 (000) 000-0000` / `10000000000`
(used for tel: and WhatsApp links) and `info@alnooracademy.com`.

## Receiving form submissions
By default both forms open the visitor's email app with the details filled in,
addressed to `CONTACT_EMAIL`. For submissions to arrive straight in your inbox
without that step, create a free form at https://formspree.io and paste its
endpoint into `FORM_ENDPOINT` (e.g. `"https://formspree.io/f/abcdwxyz"`).
