---
name: alliance-comms
description: "Standard communication pattern for the Alliance Financing dashboard (dashboard.html). Use this skill EVERY TIME you need to build, modify, or debug any email compose form, note system, or communication UI in the dashboard. Triggers include: email modal, compose form, note input, CC field, attach file, follow-up, communication section, vendor email, agent email, client email, lender email, send email button, or any mention of the communications/notes pattern in the Alliance dashboard."
---

# Alliance Financing — Communication Pattern Standard

This skill defines the canonical pattern for all email/note compose UIs across the Alliance Financing dashboard (`dashboard.html`). Every communication form — whether admin-facing or agent/ISO-facing — should follow this standard to keep the experience consistent.

## Why This Matters

The dashboard has communication forms in 6+ places (Agents, Vendors, Lenders, Clients, Website Inquiries, Vendor Contact Email). They were built at different times and have drifted apart. The Clients version is the most complete and is the gold standard. All other sections should match it.

## The Gold Standard (Clients Pattern)

Every communication compose form should include these elements, in this order:

### 1. Toggle: Note vs Email
Two buttons at the top — "+ Note" and "Send Email" — that toggle the form between note mode (internal) and email mode (external). In email mode, additional fields appear (To, CC, Subject).

### 2. Category Dropdown
A `<select>` with context-appropriate categories. Default categories:
- **General purpose**: General, Commission, Compliance, Onboarding, Follow-up
- **Lenders variant**: General, Compliance, Rates, Escalation
Categories help with filtering and searching communications later.

### 3. To Field (Email Mode)
For entities with multiple contacts (Vendors, Lenders, Clients): a dropdown or checkbox list of known contacts, plus a manual input fallback. Pre-populate from the entity's contacts in the database.

For single-recipient entities (Agents): read-only display of the agent's email.

### 4. CC Field
Always present in email mode. Format:
```html
<label>CC (external emails, comma-separated)</label>
<input type="text" placeholder="e.g. john@example.com, jane@company.com">
```

### 5. CC Shortcut Checkbox (Context-Dependent)
Where it makes sense, add a convenience checkbox:
- **Clients**: "CC Account Manager" — auto-CCs the assigned account manager
- **Vendors/Lenders (admin view)**: Quick-add buttons for known contacts
- **Agent-facing modals**: Not needed (the ISO is the one sending)

### 6. Subject Line
Pre-filled with `Re: [Entity Name]`. Editable.

### 7. Message Body
Standard textarea, resizable:
```html
<textarea placeholder="Type your message..." rows="3" style="resize:vertical;"></textarea>
```

### 8. Attach File
Uses the Supabase Storage upload pattern — NOT base64 inline attachments. The flow:
1. User picks a file via hidden `<input type="file">`
2. File name + size displays next to the button with a red "✕" to remove
3. On send, file uploads to Supabase Storage via `uploadCommFile(file, entityType, entityId)`
4. The returned `{ name, url, size, path }` object is stored in the note entry as `attachment`
5. Email body includes a download link (not an inline attachment)
6. The note/activity log renders the attachment as a clickable download link

UI pattern:
```html
<label style="display:inline-flex;align-items:center;gap:4px;padding:4px 10px;background:#F1F5F9;border:1px solid #E2E8F0;border-radius:4px;cursor:pointer;">
    Attach File
    <input type="file" style="display:none;" onchange="handleFileSelect(this)">
</label>
<span id="fileName"></span>
```

### 9. Options Row
A horizontal row of checkboxes below the message body:

| Option | Purpose | When to Include |
|--------|---------|-----------------|
| **Visible to ISO / Agent** | Makes the note visible in the agent/ISO's view | All admin-facing forms (Agents, Vendors, Clients) |
| **Pin** | Pins the note to the top of the activity feed | All forms |
| **Follow-up** | Sets a follow-up reminder with date and reason | All forms |

Follow-up expands two additional fields when checked:
```html
<input type="date" id="followupDate" style="display:none;">
<input type="text" id="followupReason" placeholder="Reason for follow-up..." style="display:none;">
```

Follow-up dates feed into the Notifications hub and show as action items when due.

### 10. Action Buttons
- **Cancel** — closes/hides the compose form
- **Send Email** / **Add Note** — gold button, label changes based on mode
- Button disables on click and changes text to "Sending..." to prevent double-submission
- Re-enables on error

### 11. Branded Email Template
All outgoing emails use the same Alliance Financing branded HTML wrapper:
```
Navy header (#0D1E3D) with gold "Alliance Financing Group" text (#C9A84C)
White body with message content
Signature block: sender name, email, "Alliance Financing Group Ltd.", phone
Gray footer: "Alliance Financing Group | alliancefinancing.ai"
```

### 12. Note Storage Pattern
Notes are stored as JSON arrays in a text column (`notes` or `admin_notes`). Each entry:
```json
{
    "text": "The message content",
    "author": "user@email.com",
    "date": "Mar 30, 2026, 02:15 PM",
    "type": "note|email",
    "visible_to_agent": true,
    "from_agent": false,
    "is_audit_log": false,
    "category": "General",
    "pinned": false,
    "followup_date": "2026-04-02",
    "followup_reason": "Check on pricing update",
    "email_to": "contact@vendor.com",
    "email_cc": "cc@example.com",
    "email_subject": "Re: Vendor Name",
    "attachment": { "name": "file.pdf", "url": "https://...", "size": 102400, "path": "comms/vendor/..." },
    "is_email": true
}
```

## Agent/ISO-Facing Modals

When an ISO or agent sends an email to a vendor contact (via `openVendorContactEmail`), the modal should include:
- **To** (read-only display of recipient)
- **CC** field
- **Subject** line
- **Message** body
- **Attach File** (same Supabase Storage pattern)
- **Category** dropdown
- **Follow-up** checkbox with date + reason (feeds into Notifications hub)

The key difference from admin forms: no "Visible to Agent" checkbox (they ARE the agent), no Pin (not applicable). But Category and Follow-up should always be present because they help the ISO track their own communications.

## Email Sending

All emails route through `sendEmailViaResend(to, subject, htmlBody, textBody, replyTo, cc)` which hits the Supabase Edge Function at `/functions/v1/send-email`. The function supports:
- `to` — primary recipient
- `cc` — array of CC addresses
- `reply_to` — defaults to sender's email so replies go to their inbox
- `html` — branded HTML body
- `text` — plain text fallback

Attachments are NOT sent inline. They're uploaded to Supabase Storage and included as download links in the email body.

## Activity Log Rendering

The `buildEntityCommsHtml(notes)` function renders the activity feed. Each entry shows:
- Author + date + badges (type, category, pin, follow-up)
- Email metadata (To, CC, Subject) if it's an email
- Attachment download link if present
- The message text

Color coding:
- Notes: light gray background
- Emails: light blue background
- Audit logs: light purple background
- Agent/ISO notes: blue accent
- Admin notes: amber accent

## Checklist for New Communication Forms

When building a new communication section, verify:
- [ ] Note vs Email toggle
- [ ] Category dropdown with appropriate options
- [ ] To field (dropdown for multi-contact entities, display for single)
- [ ] CC field (comma-separated input)
- [ ] Subject line (pre-filled with entity name)
- [ ] Message textarea
- [ ] Attach File using `uploadCommFile()` + Supabase Storage
- [ ] Visible to Agent checkbox (admin forms only)
- [ ] Pin checkbox
- [ ] Follow-up checkbox with date + reason fields
- [ ] Send button with disable-on-click protection
- [ ] Branded email template
- [ ] Note stored in JSON array with all standard fields
- [ ] Activity log renders all note types correctly

## Current Status by Section

| Section | Matches Standard? | Missing |
|---------|-------------------|---------|
| Agents & Partners | ~95% | — |
| Vendors (admin) | ~95% | — |
| Lenders | ~90% | Visible to Agent checkbox |
| Clients | 100% | Gold standard |
| Website Inquiries | N/A | No compose UI (read-only) |
| Vendor Contact Email (ISO) | ~60% | Category, Follow-up, Pin |
