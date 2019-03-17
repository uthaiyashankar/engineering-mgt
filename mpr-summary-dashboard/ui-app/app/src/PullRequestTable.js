import React from 'react';
import classNames from 'classnames';
import PropTypes from 'prop-types';
import {withStyles} from 'material-ui/styles';
import {MenuItem} from 'material-ui/Menu';
import Select from 'material-ui/Select';
import Table, {
    TableBody,
    TableCell,
    TableFooter,
    TableHead,
    TablePagination,
    TableRow,
    TableSortLabel,
} from 'material-ui/Table';
import Toolbar from 'material-ui/Toolbar';
import Typography from 'material-ui/Typography';
import Paper from 'material-ui/Paper';
import Checkbox from 'material-ui/Checkbox';
import Tooltip from 'material-ui/Tooltip';
import {lighten} from 'material-ui/styles/colorManipulator';
import axios from "axios/index";
import Button from 'material-ui/Button';
import Dialog from 'material-ui/Dialog/Dialog';
import DialogActions from 'material-ui/Dialog/DialogActions';
import DialogContent from 'material-ui/Dialog/DialogContent';
import DialogContentText from 'material-ui/Dialog/DialogContentText';
import DialogTitle from 'material-ui/Dialog/DialogTitle';

const States = ['Not Started', 'Draft Received', 'No Draft', 'In Progress', 'Issues Pending', 'Completed', 'No Impact'];
const Colors = ['#a6a7a8', '#eddd8e', '#ef4747', '#deef47', '#ef9247', '#8fef47', '#b9d7e8'];

var config = require('./config.json');

const hostUrl = config.url + config.service_path;

const columnData = [
    {id: 'prTitle', numeric: false, disablePadding: false, label: 'PR Subject'},
    {id: 'mergedDate', numeric: false, disablePadding: false, label: 'Merged Date'},
    {id: 'docStatus', numeric: false, disablePadding: false, label: 'Doc Status'},
    // { id: 'marketingStatus', numeric: false, disablePadding: false, label: 'Marketing Status' },
];

class PullRequestTableHead extends React.Component {
    createSortHandler = property => event => {
        this.props.onRequestSort(event, property);
    };

    render() {
        const {onSelectAllClick, order, orderBy, selected, data, commonStatus, handleClickOpen, editable} = this.props;

        return (
            <TableHead>
                <TableRow>
                    <TableCell padding="checkbox">
                        <Checkbox
                            indeterminate={selected.length > 0 && selected.length < data.length}
                            checked={selected.length === data.length}
                            onChange={onSelectAllClick}
                        />
                    </TableCell>
                    {columnData.map(column => {
                        return (
                            <TableCell
                                key={column.id}
                                numeric={column.numeric}
                                padding={column.disablePadding ? 'none' : 'default'}
                                sortDirection={orderBy === column.id ? order : false}
                            >
                                <Tooltip
                                    title="Sort"
                                    placement={column.numeric ? 'bottom-end' : 'bottom-start'}
                                    enterDelay={300}
                                >
                                    <TableSortLabel
                                        active={orderBy === column.id}
                                        direction={order}
                                        onClick={this.createSortHandler(column.id)}
                                    >
                                        {column.label}
                                    </TableSortLabel>
                                </Tooltip>
                                { column.id === 'docStatus' &&  selected.length > 1 && editable && <div>
                                    {"For Selected Items : "}
                                    <Select
                                        value={commonStatus}
                                        onChange={e => handleClickOpen(e, selected, true)}
                                        style={{
                                            backgroundColor: Colors[States.indexOf(commonStatus)],
                                            paddingLeft: '10px',
                                            paddingRight: '10px',
                                        }}
                                    >
                                        {States.map(state => (
                                            <MenuItem key={state} value={state}>
                                                {state}
                                            </MenuItem>
                                        ))}
                                    </Select>

                                    {!this.props.editable &&
                                    <div style={{
                                        fontSize: '1.5em',
                                    }}>
                                        {commonStatus}
                                    </div>
                                    }
                                </div>}
                            </TableCell>
                        );
                    }, this)}
                </TableRow>
            </TableHead>
        );
    }
}

PullRequestTableHead.propTypes = {
    //numSelected: PropTypes.number.isRequired,
    onRequestSort: PropTypes.func.isRequired,
    //onSelectAllClick: PropTypes.func.isRequired,
    order: PropTypes.string.isRequired,
    orderBy: PropTypes.string.isRequired,
    //rowCount: PropTypes.number.isRequired,

};

const toolbarStyles = theme => ({
    root: {
        paddingRight: theme.spacing.unit,
    },
    highlight:
        theme.palette.type === 'light'
            ? {
                color: theme.palette.secondary.main,
                backgroundColor: lighten(theme.palette.secondary.light, 0.85),
            }
            : {
                color: theme.palette.text.primary,
                backgroundColor: theme.palette.secondary.dark,
            },
    spacer: {
        flex: '1 1 100%',
    },
    actions: {
        color: theme.palette.text.secondary,
    },
    title: {
        flex: '0 0 auto',
    },
});

let PullRequestTableToolbar = props => {
    const {numSelected, classes} = props;

    return (
        <Toolbar
            className={classNames(classes.root, {
                [classes.highlight]: numSelected > 0,
            })}
        >
            <div className={classes.title}>
                {numSelected > 0 ? (
                    <Typography color="inherit" variant="subheading">
                        {numSelected} selected
                    </Typography>
                ) : (
                    <Typography variant="title">Pull Requests</Typography>
                )}
            </div>
        </Toolbar>
    );
};

PullRequestTableToolbar.propTypes = {
    classes: PropTypes.object.isRequired,
    numSelected: PropTypes.number.isRequired,
};

PullRequestTableToolbar = withStyles(toolbarStyles)(PullRequestTableToolbar);

const styles = theme => ({
    root: {
        width: '100%',
        marginTop: theme.spacing.unit * 3,
    },
    table: {
        minWidth: 800,
    },
    tableWrapper: {
        overflowX: 'auto',
    },
});

class PullRequestTable extends React.Component {
    constructor(props, context) {
        super(props, context);

        this.state = {
            order: 'asc',
            orderBy: 'milestoneName',
            selected: [],
            data: this.props.data,
            page: 0,
            rowsPerPage: 5,
            commonStatus: States[0],
            open: false,
            selectedPr: null,
            selectedDocStatus: 0
        };

        this.onStatusChanged = this.onStatusChanged.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        this.setState({data: nextProps.data});
    }

    handleRequestSort = (event, property) => {
        const orderBy = property;
        let order = 'desc';

        if (this.state.orderBy === property && this.state.order === 'desc') {
            order = 'asc';
        }


        if (orderBy !== 'mergedDate') {
            const data =
                order === 'desc'
                    ? this.state.data.sort((a, b) => (b[orderBy] < a[orderBy] ? -1 : 1))
                    : this.state.data.sort((a, b) => (a[orderBy] < b[orderBy] ? -1 : 1));

            this.setState({data, order, orderBy});
        } else {
            const data =
                order === 'desc'
                    ? this.state.data.sort((a, b) => {
                        var dayA = new Date(a[orderBy].time);
                        var dayB = new Date(b[orderBy].time);
                        return dayA > dayB ? -1 : 1;
                    })
                    : this.state.data.sort((a, b) => {
                        var dayA = new Date(a[orderBy].time);
                        var dayB = new Date(b[orderBy].time);
                        return dayA < dayB ? -1 : 1;
                    });

            this.setState({data, order, orderBy});
        }
    };

    handleSelectAllClick = (event, checked) => {
        if (checked) {
            this.setState({selected: this.state.data.map(n => n.prId)});
            return;
        }
        this.setState({selected: []});
    };

    handleClick = (event, id) => {
        const {selected} = this.state;
        const selectedIndex = selected.indexOf(id);
        let newSelected = [];

        if (selectedIndex === -1) {
            newSelected = newSelected.concat(selected, id);
        } else if (selectedIndex === 0) {
            newSelected = newSelected.concat(selected.slice(1));
        } else if (selectedIndex === selected.length - 1) {
            newSelected = newSelected.concat(selected.slice(0, -1));
        } else if (selectedIndex > 0) {
            newSelected = newSelected.concat(
                selected.slice(0, selectedIndex),
                selected.slice(selectedIndex + 1),
            );
        }

        this.setState({
            selected: newSelected,
            commonStatus: States[0]
        });
    };

    handleChangePage = (event, page) => {
        this.setState({page});
    };

    handleChangeRowsPerPage = event => {
        this.setState({rowsPerPage: event.target.value});
    };

    isSelected = id => this.state.selected.indexOf(id) !== -1;

    onStatusChanged(docStatus, prId, isDoc, isSendMail) {
        var i = 0;
        const pullRequests = this.state.data;
        for (i = 0; i < pullRequests.length; i++) {
            if (pullRequests[i].prId !== prId) {
            } else {
                var value = docStatus;
                if (isDoc) {
                    pullRequests[i].docStatus = value;
                    pullRequests[i].docSendEmail = false;
                    if (value === 2 || value === 4) {
                        if (isSendMail === true) {
                            pullRequests[i].docSendEmail = true;
                        }
                    }
                } else {
                    pullRequests[i].marketingStatus = value;
                }

                axios.post(hostUrl + '/setdoc', {
                    records: [{
                        prId: prId,
                        docStatus: isDoc ? value : pullRequests[i].docStatus,
                        docSendEmail: !!pullRequests[i].docSendEmail,
                        marketingStatus: !isDoc ? value : pullRequests[i].marketingStatus,
                    }],
                })
                    .then(response => {
                        console.log(response);
                    })
                    .catch(error => {
                        console.log(error);
                    });


                break;
            }
        }
        this.setState({data: pullRequests});
    }

    onBatchStatusChanges(docStatus, isDoc, data, selected, isSendMail) {
        var records = [];
        console.log('states', this.state);
        const pullRequests = data;
        var value = docStatus;
        selected.map(prId => {
            var i = 0;
            for (i = 0; i < pullRequests.length; i++) {
                if (pullRequests[i].prId !== prId) {
                } else {
                    if (isDoc) {
                        pullRequests[i].docStatus = value;
                        pullRequests[i].docSendEmail = false;
                        if (value === 2 || value === 4) {
                            if (isSendMail === true) {
                                pullRequests[i].docSendEmail = true;
                            }
                        }
                    } else {
                        pullRequests[i].marketingStatus = value;
                    }
                    records.push({
                        prId: prId,
                        docStatus: isDoc ? value : pullRequests[i].docStatus,
                        docSendEmail: !!pullRequests[i].docSendEmail,
                        marketingStatus: !isDoc ? value : pullRequests[i].marketingStatus,
                    });
                    break;
                }
            }

        });
        axios.post(hostUrl + '/setdoc', {
            records: records,
        })
            .then(response => {
                console.log(response);
                this.setState({
                    data: pullRequests,
                    commonStatus: States[docStatus]
                });
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleClickOpen = (event, prId, isBatchData) => {
        var value = States.indexOf(event.target.value);
        if (value === 2 || value === 4) {
            this.setState({
                open: true,
                selectedPr: prId,
                selectedDocStatus: value
            });
        } else {
            if (isBatchData) {
                this.onBatchStatusChanges(value, true, this.state.data, prId, false)
            } else {
                this.onStatusChanged(value, prId, true, false);
            }
        }
    };

    handleYes = () => {
        if (Array.isArray(this.state.selectedPr)) {
            this.onBatchStatusChanges(this.state.selectedDocStatus, true, this.state.data, this.state.selectedPr, true)
        } else {
            this.onStatusChanged(this.state.selectedDocStatus, this.state.selectedPr, true, true);
        }
        this.setState({
            open: false,
            selectedPr: null,
            selectedDocStatus: 0
        });
    };

    handleNo = () => {
        if (Array.isArray(this.state.selectedPr)) {
            this.onBatchStatusChanges(this.state.selectedDocStatus, true, this.state.data, this.state.selectedPr, false)
        } else {
            this.onStatusChanged(this.state.selectedDocStatus, this.state.selectedPr, true, false, false);
        }
        this.setState({
            open: false,
            selectedPr: null,
            selectedDocStatus: 0
        });
    };

    render() {
        const {classes} = this.props;
        const {data, order, orderBy, selected, rowsPerPage, page, commonStatus} = this.state;
        const emptyRows = rowsPerPage - Math.min(rowsPerPage, data.length - page * rowsPerPage);

//        console.log(States);
//        console.log('back color', Colors[States.indexOf(commonStatus)], commonStatus, States.indexOf(commonStatus));

        return (
            <Paper className={classes.root}>
                {/*<PullRequestTableToolbar numSelected={selected.length} />*/}
                <div className={classes.tableWrapper}>
                    <Table className={classes.table}>
                        <PullRequestTableHead
                            selected={selected}
                            commonStatus={commonStatus}
                            order={order}
                            orderBy={orderBy}
                            onSelectAllClick={this.handleSelectAllClick}
                            onRequestSort={this.handleRequestSort}
                            onBatchStatusChanges={this.onBatchStatusChanges.bind(this)}
                            handleClickOpen={this.handleClickOpen.bind(this)}
                            data={data}
                            editable={this.props.editable}
                        />
                        <TableBody>
                            {data.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(n => {
                                const isSelected = this.isSelected(n.prId);
                                return (
                                    <TableRow
                                        hover
                                        onClick={event => this.handleClick(event, n.prId)}
                                        role="checkbox"
                                        aria-checked={isSelected}
                                        tabIndex={-1}
                                        key={n.prId}
                                        selected={isSelected}
                                    >
                                        <TableCell padding="checkbox">
                                        <Checkbox checked={isSelected} />
                                        </TableCell>
                                        <TableCell>{
                                            <a href={n.prUrl} target={'_blank'}>
                                                {n.prTitle}
                                            </a>
                                        }</TableCell>
                                        <TableCell>{(new Date(n.mergedDate.time)).toUTCString()}</TableCell>
                                        <TableCell>{
                                            <div>
                                                {this.props.editable &&
                                                <Select
                                                    value={States[n.docStatus]}
                                                    onChange={e => this.handleClickOpen(e, n.prId, false)}
                                                    style={{
                                                        backgroundColor: Colors[n.docStatus],
                                                        paddingLeft: '10px',
                                                        paddingRight: '10px',
                                                    }}
                                                >
                                                    {States.map(state => (
                                                        <MenuItem key={state} value={state}>
                                                            {state}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                                }
                                                {!this.props.editable &&
                                                <div style={{
                                                    fontSize: '1.5em',
                                                    backgroundColor: Colors[n.docStatus],
                                                    paddingLeft: '10px',
                                                    paddingRight: '10px',
                                                }}>
                                                    {States[n.docStatus]}
                                                </div>
                                                }
                                            </div>
                                        }</TableCell>
                                        {/*<TableCell>{*/}
                                        {/*<div style={{*/}
                                        {/*backgroundColor: Colors[n.marketingStatus],*/}
                                        {/*}}>*/}
                                        {/*{this.props.editable &&*/}
                                        {/*<Select*/}
                                        {/*value={States[n.marketingStatus]}*/}
                                        {/*onChange={e => this.onStatusChanged(e, n.prId, false)}*/}
                                        {/*>*/}
                                        {/*{States.map(state => (*/}
                                        {/*<MenuItem key={state} value={state}>*/}
                                        {/*{state}*/}
                                        {/*</MenuItem>*/}
                                        {/*))}*/}
                                        {/*</Select>*/}
                                        {/*}*/}
                                        {/*{!this.props.editable &&*/}
                                        {/*<div style={{*/}
                                        {/*fontSize:'1.5em',*/}
                                        {/*}}>*/}
                                        {/*{States[n.marketingStatus]}*/}
                                        {/*</div>*/}
                                        {/*}*/}
                                        {/*</div>*/}
                                        {/*}</TableCell>*/}
                                    </TableRow>
                                );
                            })}
                            {emptyRows > 0 && (
                                <TableRow style={{height: 49 * emptyRows}}>
                                    <TableCell colSpan={6}/>
                                </TableRow>
                            )}
                        </TableBody>
                        <TableFooter>
                            <TableRow>
                                <TablePagination
                                    colSpan={6}
                                    count={data.length}
                                    rowsPerPage={rowsPerPage}
                                    page={page}
                                    backIconButtonProps={{
                                        'aria-label': 'Previous Page',
                                    }}
                                    nextIconButtonProps={{
                                        'aria-label': 'Next Page',
                                    }}
                                    onChangePage={this.handleChangePage}
                                    onChangeRowsPerPage={this.handleChangeRowsPerPage}
                                />
                            </TableRow>
                        </TableFooter>
                    </Table>
                    <Dialog
                        open={this.state.open}
                        onClose={this.handleNo}
                        aria-labelledby="alert-dialog-title"
                        aria-describedby="alert-dialog-description"
                    >
                        <DialogTitle id="alert-dialog-title">{"Email Confirmation"}</DialogTitle>
                        <DialogContent>
                            <DialogContentText id="alert-dialog-description">
                                This will send a Email to PR author! Please confirm
                            </DialogContentText>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={this.handleYes} color="primary">
                                Yes
                            </Button>
                            <Button onClick={this.handleNo} color="primary" autoFocus>
                                No
                            </Button>
                        </DialogActions>
                    </Dialog>
                </div>
            </Paper>
        );
    }
}

PullRequestTable.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(PullRequestTable);
